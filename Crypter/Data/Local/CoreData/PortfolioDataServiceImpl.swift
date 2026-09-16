//
//  PortfolioDataService.swift
//  Crypter
//
//

import Foundation
import CoreData
import Combine

/// A position derived from the user's transactions.
struct PortfolioHolding: Identifiable, Equatable {
    let coinID: String
    let amount: Double

    /// Average price paid per coin, or `nil` when the basis is unknown
    /// (holdings that predate transaction tracking).
    let averageCost: Double?

    var id: String { coinID }
}

enum TransactionKind: String, CaseIterable, Identifiable {
    case buy
    case sell
    /// A holding carried over from before transactions existed, with no known price.
    case opening

    var id: String { rawValue }

    var title: String {
        switch self {
        case .buy: return "Buy"
        case .sell: return "Sell"
        case .opening: return "Opening balance"
        }
    }

    var iconName: String {
        switch self {
        case .buy: return "arrow.down.left"
        case .sell: return "arrow.up.right"
        case .opening: return "clock.arrow.circlepath"
        }
    }
}

/// A transaction with its Core Data values already unwrapped.
struct PortfolioTransaction: Identifiable, Equatable {
    let id: UUID
    let coinID: String
    let kind: TransactionKind
    let amount: Double
    let pricePerCoin: Double
    let hasCostBasis: Bool
    let date: Date

    var totalValue: Double { amount * pricePerCoin }

    /// Signed change this transaction applies to the holding.
    var signedAmount: Double {
        kind == .sell ? -amount : amount
    }
}

protocol PortfolioDataService {
    var savedEntitiesPublisher: AnyPublisher<[PortfolioHolding], Never> { get }
    /// Set when the local store could not be opened, so the UI can say so
    /// instead of pretending the portfolio is empty.
    var storeErrorPublisher: AnyPublisher<String?, Never> { get }
    var transactionsPublisher: AnyPublisher<[PortfolioTransaction], Never> { get }

    func addTransaction(coin: CoinModel, kind: TransactionKind, amount: Double, pricePerCoin: Double, date: Date)
    func updateTransaction(id: UUID, kind: TransactionKind, amount: Double, pricePerCoin: Double, date: Date)
    func deleteTransaction(id: UUID)
    func setCostBasis(forCoinID coinID: String, pricePerCoin: Double)
    func deleteAllTransactions(forCoinID coinID: String)
    func deleteAllTransactions()
    func holding(forCoinID coinID: String) -> PortfolioHolding?
    func transactions(forCoinID coinID: String) -> [PortfolioTransaction]
}

enum CoreDataError: Error {
    case saving
    case fetching
    case loadFail(error: Error)

    var description: String {
        switch self {
        case .saving:
            return "Error saving to core data"
        case .fetching:
            return "Error Fetching from coredata"
        case .loadFail:
            return "Error Loading CoreData"
        }
    }
}

class PortfolioDataServiceImpl: PortfolioDataService {
    private let container: NSPersistentContainer
    private let containerName: String = "PortfolioContainer"
    private let legacyEntityName: String = "PortfolioEntity"
    private let entityName: String = "TransactionEntity"

    private let holdingsSubject = CurrentValueSubject<[PortfolioHolding], Never>([])
    private let transactionsSubject = CurrentValueSubject<[PortfolioTransaction], Never>([])
    private let storeErrorSubject = CurrentValueSubject<String?, Never>(nil)

    var savedEntitiesPublisher: AnyPublisher<[PortfolioHolding], Never> {
        holdingsSubject.eraseToAnyPublisher()
    }

    var transactionsPublisher: AnyPublisher<[PortfolioTransaction], Never> {
        transactionsSubject.eraseToAnyPublisher()
    }

    var storeErrorPublisher: AnyPublisher<String?, Never> {
        storeErrorSubject.eraseToAnyPublisher()
    }

    var savedHoldings: [PortfolioHolding] {
        holdingsSubject.value
    }

    init()  {
        container = NSPersistentContainer(name: containerName)
        var initError: Error?
        container.loadPersistentStores { (_, error) in
            initError = error
        }

        if let initError {
            storeErrorSubject.send("Couldn't open your saved portfolio. Recent changes may not be showing.")
            print("Error loading Core Data store. \(initError)")
            return
        }

        migrateLegacyHoldingsIfNeeded()
        reload()
    }

    // MARK: PUBLIC

    func addTransaction(coin: CoinModel, kind: TransactionKind, amount: Double, pricePerCoin: Double, date: Date) {
        guard amount > 0 else { return }

        let entity = TransactionEntity(context: container.viewContext)
        entity.id = UUID()
        entity.coinID = coin.id
        entity.kind = kind.rawValue
        entity.amount = amount
        entity.pricePerCoin = pricePerCoin
        entity.hasCostBasis = kind != .opening
        entity.date = date

        applyChanges()
    }

    func updateTransaction(id: UUID, kind: TransactionKind, amount: Double, pricePerCoin: Double, date: Date) {
        guard amount > 0 else { return }

        let request = NSFetchRequest<TransactionEntity>(entityName: entityName)
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        guard let entity = try? container.viewContext.fetch(request).first else { return }

        entity.kind = kind.rawValue
        entity.amount = amount
        entity.pricePerCoin = pricePerCoin
        entity.hasCostBasis = kind != .opening
        entity.date = date

        applyChanges()
    }

    func deleteTransaction(id: UUID) {
        let request = NSFetchRequest<TransactionEntity>(entityName: entityName)
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        guard let entity = try? container.viewContext.fetch(request).first else { return }

        container.viewContext.delete(entity)
        applyChanges()
    }

    /// Turns a coin's opening balance into a buy at the given price, so holdings
    /// carried over from before transaction tracking can join the all-time P/L.
    func setCostBasis(forCoinID coinID: String, pricePerCoin: Double) {
        guard pricePerCoin > 0 else { return }

        let request = NSFetchRequest<TransactionEntity>(entityName: entityName)
        request.predicate = NSPredicate(
            format: "coinID == %@ AND kind == %@",
            coinID,
            TransactionKind.opening.rawValue
        )

        guard let entities = try? container.viewContext.fetch(request), !entities.isEmpty else { return }

        for entity in entities {
            entity.kind = TransactionKind.buy.rawValue
            entity.pricePerCoin = pricePerCoin
            entity.hasCostBasis = true
        }

        applyChanges()
    }

    func deleteAllTransactions(forCoinID coinID: String) {
        let request = NSFetchRequest<TransactionEntity>(entityName: entityName)
        request.predicate = NSPredicate(format: "coinID == %@", coinID)

        guard let entities = try? container.viewContext.fetch(request) else { return }

        entities.forEach { container.viewContext.delete($0) }
        applyChanges()
    }

    /// Wipes every transaction, for the "reset portfolio" action in Settings.
    func deleteAllTransactions() {
        let request = NSFetchRequest<TransactionEntity>(entityName: entityName)

        guard let entities = try? container.viewContext.fetch(request) else { return }

        entities.forEach { container.viewContext.delete($0) }
        applyChanges()
    }

    func holding(forCoinID coinID: String) -> PortfolioHolding? {
        savedHoldings.first(where: { $0.coinID == coinID })
    }

    func transactions(forCoinID coinID: String) -> [PortfolioTransaction] {
        transactionsSubject.value.filter { $0.coinID == coinID }
    }

    // MARK: PRIVATE

    /// Holdings recorded before transactions existed become opening balances with
    /// no cost basis, so nothing is invented and the quantities are preserved.
    private func migrateLegacyHoldingsIfNeeded() {
        let request = NSFetchRequest<PortfolioEntity>(entityName: legacyEntityName)

        guard let legacyEntities = try? container.viewContext.fetch(request), !legacyEntities.isEmpty else {
            return
        }

        for legacy in legacyEntities {
            if let coinID = legacy.coinID, legacy.amount > 0 {
                let entity = TransactionEntity(context: container.viewContext)
                entity.id = UUID()
                entity.coinID = coinID
                entity.kind = TransactionKind.opening.rawValue
                entity.amount = legacy.amount
                entity.pricePerCoin = 0
                entity.hasCostBasis = false
                entity.date = Date()
            }

            container.viewContext.delete(legacy)
        }

        save()
    }

    private func reload() {
        let request = NSFetchRequest<TransactionEntity>(entityName: entityName)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        do {
            let entities = try container.viewContext.fetch(request)
            let transactions = entities.compactMap(Self.makeTransaction)
            transactionsSubject.send(transactions)
            holdingsSubject.send(Self.holdings(from: transactions))
        } catch let error {
            print("Error fetching transactions. \(error)")
        }
    }

    private static func makeTransaction(from entity: TransactionEntity) -> PortfolioTransaction? {
        guard let id = entity.id,
              let coinID = entity.coinID,
              let kind = TransactionKind(rawValue: entity.kind ?? "") else {
            return nil
        }

        return PortfolioTransaction(
            id: id,
            coinID: coinID,
            kind: kind,
            amount: entity.amount,
            pricePerCoin: entity.pricePerCoin,
            hasCostBasis: entity.hasCostBasis,
            date: entity.date ?? Date()
        )
    }

    /// Profit locked in by each sell, keyed by transaction id.
    ///
    /// A sell only has a realized figure when the coins it sold had a known
    /// cost, so sells drawn from an opening balance are absent rather than
    /// reported as pure profit.
    static func realizedProfits(from transactions: [PortfolioTransaction]) -> [UUID: Double] {
        var result: [UUID: Double] = [:]
        let byCoin = Dictionary(grouping: transactions, by: { $0.coinID })

        for (_, coinTransactions) in byCoin {
            var amount: Double = 0
            var costTotal: Double = 0
            var basisKnown = true

            for transaction in coinTransactions.sorted(by: { $0.date < $1.date }) {
                switch transaction.kind {
                case .buy:
                    amount += transaction.amount
                    costTotal += transaction.totalValue
                case .opening:
                    amount += transaction.amount
                    basisKnown = false
                case .sell:
                    let averageCost = amount > 0 ? costTotal / amount : 0
                    let sold = min(transaction.amount, amount)

                    if basisKnown, sold > 0 {
                        result[transaction.id] = (transaction.pricePerCoin - averageCost) * sold
                    }

                    amount -= sold
                    costTotal -= averageCost * sold
                }
            }
        }

        return result
    }

    /// True when no sell in the list is larger than the amount held at that point.
    /// Used to reject an edit that would make an earlier history impossible.
    static func isConsistent(_ transactions: [PortfolioTransaction]) -> Bool {
        let byCoin = Dictionary(grouping: transactions, by: { $0.coinID })

        for (_, coinTransactions) in byCoin {
            var amount: Double = 0

            for transaction in coinTransactions.sorted(by: { $0.date < $1.date }) {
                switch transaction.kind {
                case .buy, .opening:
                    amount += transaction.amount
                case .sell:
                    if transaction.amount > amount + 0.000_000_01 { return false }
                    amount -= transaction.amount
                }
            }
        }

        return true
    }

    /// Average-cost accounting: buys raise the basis, sells reduce the quantity at
    /// the running average, and any opening balance leaves the basis unknown.
    static func holdings(from transactions: [PortfolioTransaction]) -> [PortfolioHolding] {
        let byCoin = Dictionary(grouping: transactions, by: { $0.coinID })

        return byCoin.compactMap { coinID, coinTransactions -> PortfolioHolding? in
            var amount: Double = 0
            var costTotal: Double = 0
            var basisKnown = true

            for transaction in coinTransactions.sorted(by: { $0.date < $1.date }) {
                switch transaction.kind {
                case .buy:
                    amount += transaction.amount
                    costTotal += transaction.totalValue
                case .opening:
                    amount += transaction.amount
                    basisKnown = false
                case .sell:
                    let averageCost = amount > 0 ? costTotal / amount : 0
                    let sold = min(transaction.amount, amount)
                    amount -= sold
                    costTotal -= averageCost * sold
                }
            }

            guard amount > 0 else { return nil }

            return PortfolioHolding(
                coinID: coinID,
                amount: amount,
                averageCost: basisKnown && costTotal > 0 ? costTotal / amount : nil
            )
        }
    }

    private func save() {
        do {
            try container.viewContext.save()
        } catch let error {
            print("Error saving to Core Data. \(error)")
        }
    }

    private func applyChanges() {
        save()
        reload()
    }
}
