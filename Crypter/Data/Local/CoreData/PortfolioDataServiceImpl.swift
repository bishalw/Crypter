//
//  PortfolioDataService.swift
//  Crypter
//
//

import Foundation
import CoreData

protocol PortfolioDataService {
    func updatePortfolio(coin: CoinModel, amount: Double)
}

class PortfolioDataServiceImpl {
    
    private let container: NSPersistentContainer
    private let containerName: String = "PortfolioContainer"
    private let entityName: String = "PortfolioEntity"
    
    @Published var savedEntites: [PortfolioEntity] = []
    
    init(){
        // on init setting the container
        container = NSPersistentContainer(name: containerName)
        // loading core data on initialization
        container.loadPersistentStores { (_, error) in
            if let error = error {
                print("Error loading Core Data! \(error)")
            }
            self.getPortfolio()
        }
    }
    
    //MARK: PUBLIC
    
    func updatePortfolio(coin: CoinModel, amount: Double) {
        
        if let entity = savedEntites.first(where: { $0.coinID == coin.id }) {
            
            if amount > 0 {
                update(entity: entity, amount: amount)
            } else {
                delete(entity: entity)
            }
        } else {
            add(coin: coin, amount: amount)
            
        }
    }
    
    //MARK: PRIVATE
    
    private func getPortfolio() {
        let request = NSFetchRequest<PortfolioEntity>(entityName: entityName)
        do {
           savedEntites = try container.viewContext.fetch(request)
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
