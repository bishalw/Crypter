//
//  PortfolioHoldingsTests.swift
//  CrypterTests
//

import XCTest
@testable import Crypter

/// Covers the average-cost accounting that turns a list of transactions into a
/// position. This is money arithmetic, so the sell path in particular is worth
/// pinning down.
final class PortfolioHoldingsTests: XCTestCase {

    private let coinID = "bitcoin"

    private func transaction(
        _ kind: TransactionKind,
        amount: Double,
        price: Double,
        daysAgo: Int = 0,
        coinID: String? = nil
    ) -> PortfolioTransaction {
        PortfolioTransaction(
            id: UUID(),
            coinID: coinID ?? self.coinID,
            kind: kind,
            amount: amount,
            pricePerCoin: price,
            hasCostBasis: kind != .opening,
            date: Date().addingTimeInterval(TimeInterval(-daysAgo * 86_400))
        )
    }

    private func holding(_ transactions: [PortfolioTransaction], coinID: String? = nil) -> PortfolioHolding? {
        PortfolioDataServiceImpl.holdings(from: transactions)
            .first(where: { $0.coinID == (coinID ?? self.coinID) })
    }

    func test_singleBuy_setsAmountAndCost() {
        let result = holding([transaction(.buy, amount: 2, price: 600)])

        XCTAssertEqual(result?.amount, 2)
        XCTAssertEqual(result?.averageCost, 600)
    }

    func test_twoBuysAtDifferentPrices_averagesTheCost() {
        let result = holding([
            transaction(.buy, amount: 1, price: 100, daysAgo: 2),
            transaction(.buy, amount: 3, price: 200, daysAgo: 1),
        ])

        // (100 + 600) / 4
        XCTAssertEqual(result?.amount, 4)
        XCTAssertEqual(result?.averageCost, 175)
    }

    func test_sell_reducesAmountButKeepsAverageCost() {
        let result = holding([
            transaction(.buy, amount: 1, price: 100, daysAgo: 3),
            transaction(.buy, amount: 3, price: 200, daysAgo: 2),
            transaction(.sell, amount: 2, price: 500, daysAgo: 1),
        ])

        // Selling at the running average leaves the average untouched.
        XCTAssertEqual(result?.amount, 2)
        XCTAssertEqual(result?.averageCost, 175)
    }

    func test_sellingEverything_dropsTheHolding() {
        let result = holding([
            transaction(.buy, amount: 2, price: 100, daysAgo: 1),
            transaction(.sell, amount: 2, price: 150),
        ])

        XCTAssertNil(result)
    }

    func test_sellingMoreThanHeld_clampsToZeroRatherThanGoingNegative() {
        let result = holding([
            transaction(.buy, amount: 1, price: 100, daysAgo: 1),
            transaction(.sell, amount: 5, price: 150),
        ])

        XCTAssertNil(result)
    }

    func test_openingBalance_keepsAmountButLeavesCostUnknown() {
        let result = holding([transaction(.opening, amount: 500, price: 0)])

        XCTAssertEqual(result?.amount, 500)
        XCTAssertNil(result?.averageCost)
    }

    func test_openingBalancePlusBuy_stillReportsUnknownCost() {
        let result = holding([
            transaction(.opening, amount: 1, price: 0, daysAgo: 2),
            transaction(.buy, amount: 1, price: 400, daysAgo: 1),
        ])

        // Part of the position has no known price, so no honest average exists.
        XCTAssertEqual(result?.amount, 2)
        XCTAssertNil(result?.averageCost)
    }

    func test_transactionsAreAppliedInDateOrderNotArrayOrder() {
        // Newest first, the order the store fetches them in.
        let result = holding([
            transaction(.sell, amount: 1, price: 900, daysAgo: 1),
            transaction(.buy, amount: 2, price: 100, daysAgo: 5),
        ])

        XCTAssertEqual(result?.amount, 1)
        XCTAssertEqual(result?.averageCost, 100)
    }

    func test_coinsAreKeptSeparate() {
        let transactions = [
            transaction(.buy, amount: 2, price: 100),
            transaction(.buy, amount: 10, price: 5, coinID: "solana"),
        ]

        XCTAssertEqual(holding(transactions)?.amount, 2)
        XCTAssertEqual(holding(transactions, coinID: "solana")?.amount, 10)
        XCTAssertEqual(PortfolioDataServiceImpl.holdings(from: transactions).count, 2)
    }

    func test_noTransactions_yieldsNoHoldings() {
        XCTAssertTrue(PortfolioDataServiceImpl.holdings(from: []).isEmpty)
    }

    // MARK: - Realized profit

    func test_sellAboveAverageCost_realizesTheDifference() {
        let sell = transaction(.sell, amount: 1, price: 150)
        let profits = PortfolioDataServiceImpl.realizedProfits(from: [
            transaction(.buy, amount: 2, price: 100, daysAgo: 1),
            sell,
        ])

        XCTAssertEqual(profits[sell.id] ?? 0, 50, accuracy: 0.0001)
    }

    func test_sellBelowAverageCost_realizesALoss() {
        let sell = transaction(.sell, amount: 2, price: 80)
        let profits = PortfolioDataServiceImpl.realizedProfits(from: [
            transaction(.buy, amount: 2, price: 100, daysAgo: 1),
            sell,
        ])

        XCTAssertEqual(profits[sell.id] ?? 0, -40, accuracy: 0.0001)
    }

    func test_sellFromAnOpeningBalance_hasNoRealizedFigure() {
        let sell = transaction(.sell, amount: 1, price: 150)
        let profits = PortfolioDataServiceImpl.realizedProfits(from: [
            transaction(.opening, amount: 2, price: 0, daysAgo: 1),
            sell,
        ])

        XCTAssertNil(profits[sell.id])
    }

    func test_buysDoNotRealizeAnything() {
        let buy = transaction(.buy, amount: 1, price: 100)

        XCTAssertTrue(PortfolioDataServiceImpl.realizedProfits(from: [buy]).isEmpty)
    }

    // MARK: - Consistency checks used when editing

    func test_historyIsConsistentWhenSellsFitWithinHoldings() {
        XCTAssertTrue(PortfolioDataServiceImpl.isConsistent([
            transaction(.buy, amount: 2, price: 100, daysAgo: 2),
            transaction(.sell, amount: 2, price: 150, daysAgo: 1),
        ]))
    }

    func test_historyIsInconsistentWhenASellExceedsWhatWasHeld() {
        XCTAssertFalse(PortfolioDataServiceImpl.isConsistent([
            transaction(.buy, amount: 1, price: 100, daysAgo: 2),
            transaction(.sell, amount: 2, price: 150, daysAgo: 1),
        ]))
    }

    func test_aSellBeforeItsBuyIsInconsistent() {
        XCTAssertFalse(PortfolioDataServiceImpl.isConsistent([
            transaction(.buy, amount: 5, price: 100, daysAgo: 1),
            transaction(.sell, amount: 5, price: 150, daysAgo: 3),
        ]))
    }

    // MARK: - Profit reporting on the coin model

    func test_profitIsReportedAgainstAverageCost() {
        let coin = DeveloperPreview.instance.coin.updatePosition(amount: 2, averageCost: 600)
        let expectedValue = 2 * coin.currentPrice

        XCTAssertEqual(coin.costBasisValue, 1200)
        XCTAssertEqual(coin.totalProfit ?? 0, expectedValue - 1200, accuracy: 0.0001)
        XCTAssertEqual(coin.totalProfitPercentage ?? 0, ((expectedValue - 1200) / 1200) * 100, accuracy: 0.0001)
    }

    func test_profitIsUnavailableWithoutACostBasis() {
        let coin = DeveloperPreview.instance.coin.updatePosition(amount: 2, averageCost: nil)

        XCTAssertNil(coin.costBasisValue)
        XCTAssertNil(coin.totalProfit)
        XCTAssertNil(coin.totalProfitPercentage)
    }
}
