//
//  PortfolioDataService.swift
//  Crypter
//
//

import Foundation
import CoreData
import Combine

protocol PortfolioDataService {
    var savedEntitiesPublisher: AnyPublisher<[PortfolioEntity], Never> { get }
    func updatePortfolio(coin: CoinModel, amount: Double)
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
    private let entityName: String = "PortfolioEntity"
    
    private let savedEntitiesSubject = CurrentValueSubject<[PortfolioEntity], Never>([])
    
    var savedEntitiesPublisher: AnyPublisher<[PortfolioEntity], Never> {
        savedEntitiesSubject.eraseToAnyPublisher()
    }
    
    var savedEntities: [PortfolioEntity] {
        savedEntitiesSubject.value
    }
    
    init()  {
        container = NSPersistentContainer(name: containerName)
        var initError: Error?
        container.loadPersistentStores { (_, error) in
            initError = error
        }
        
        if initError != nil {
            print("error")
        }

        getPortfolio()
    }
    
    // MARK: PUBLIC
    
    func updatePortfolio(coin: CoinModel, amount: Double) {
        if let entity = savedEntities.first(where: { $0.coinID == coin.id }) {
            if amount > 0 {
                update(entity: entity, amount: amount)
            } else {
                delete(entity: entity)
            }
        } else if amount > 0 {
            add(coin: coin, amount: amount)
        }
    }
    
    // MARK: PRIVATE
    
    private func getPortfolio() {
        let request = NSFetchRequest<PortfolioEntity>(entityName: entityName)
        do {
            let entities = try container.viewContext.fetch(request)
            savedEntitiesSubject.send(entities)
        } catch let error {
            print("Error fetching Portfolio Entities. \(error)")
        }
    }
    
    private func add(coin: CoinModel, amount: Double) {
        let entity = PortfolioEntity(context: container.viewContext)
        entity.coinID = coin.id
        entity.amount = amount
        applyChanges()
    }
    
    private func update(entity: PortfolioEntity, amount: Double) {
        entity.amount = amount
        applyChanges()
    }
    
    private func delete(entity: PortfolioEntity) {
        container.viewContext.delete(entity)
        applyChanges()
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
        getPortfolio()
    }
}
