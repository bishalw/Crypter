//
//  CoinAPIServiceImplTests.swift
//  CrypterTests
//
import XCTest
import Combine
@testable import Crypter

class CoinAPIServiceImplTests: XCTestCase {
    
    var sut: CoinAPIServiceImpl!
    var networkingManager: NetworkingManagerMock!
    
    override func setUpWithError() throws {
        networkingManager = NetworkingManagerMock()
        sut = CoinAPIServiceImpl(networkingManager: networkingManager)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        networkingManager = nil
    }
    
    func testFetchAllCoins() throws {
        // Given
        let coinsURL = URL(string: "https://example.com/coins")!
        let expectedCoins = CoinDTO(coins: [])
        networkingManager.downloadStub = Result.Publisher(expectedCoins).eraseToAnyPublisher()
        
        // When
        let result = try sut.fetchAllCoins().eraseToAnyPublisher().collect().last().await(timeout: 1)
        
        // Then
        XCTAssertEqual(networkingManager.downloadCallCount, 1)
        XCTAssertEqual(networkingManager.downloadURLs, [coinsURL])
        XCTAssertEqual(result, [expectedCoins])
    }
    
    func testFetchCoinDetail() throws {
        // Given
        let coin = CoinModel(id: "BTC", name: "Bitcoin")
        let coinDetailURL = URL(string: "https://example.com/coin/BTC")!
        let expectedCoinDetail = CoinDetailDTO(id: "BTC", name: "Bitcoin", price: 50000)
        networkingManager.downloadStub = Result.Publisher(expectedCoinDetail).eraseToAnyPublisher()
        
        // When
        let result = try sut.fetchCoinDetail(coin: coin).eraseToAnyPublisher().collect().last().await(timeout: 1)
        
        // Then
        XCTAssertEqual(networkingManager.downloadCallCount, 1)
        XCTAssertEqual(networkingManager.downloadURLs, [coinDetailURL])
        XCTAssertEqual(result, [expectedCoinDetail])
    }
    
    func testFetchGlobalData() throws {
        // Given
        let globalDataURL = URL(string: "https://example.com/globalData")!
        let expectedGlobalData = GlobalDataDTO(totalCoins: 5000, marketCap: 1000000)
        networkingManager.downloadStub = Result.Publisher(expectedGlobalData).eraseToAnyPublisher()
        
        // When
        let result = try sut.fetchGlobalData().eraseToAnyPublisher().collect().last().await(timeout: 1)
        
        // Then
        XCTAssertEqual(networkingManager.downloadCallCount, 1)
        XCTAssertEqual(networkingManager.downloadURLs, [globalDataURL])
        XCTAssertEqual(result, [expectedGlobalData])
    }
}

// MARK: - NetworkingManagerMock

class NetworkingManagerMock: NetworkingManager {
    var downloadCallCount = 0
    var downloadURLs = [URL]()
    var downloadStub: AnyPublisher<Decodable, Error>?
    
    func download<T>(url: URL, decodingType: T.Type) -> AnyPublisher<T, Error> where T : Decodable {
        downloadCallCount += 1
        downloadURLs.append(url)
        return downloadStub as! AnyPublisher<T, Error>
    }
}