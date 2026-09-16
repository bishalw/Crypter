//
//  CSVTransactionParserTests.swift
//  CrypterTests
//

import XCTest
@testable import Crypter

final class CSVTransactionParserTests: XCTestCase {

    private let header = "date,coin,type,amount,price_per_coin,total,has_cost_basis"

    func test_parsesTheFormatExportWrites() throws {
        let rows = try CSVTransactionParser.parse("""
        \(header)
        2026-09-15,bitcoin,buy,0.5,60000.0,30000.0,yes
        2026-09-16,ethereum,sell,2.0,4000.0,8000.0,yes
        """)

        XCTAssertEqual(rows.count, 2)
        XCTAssertEqual(rows.first?.coinID, "bitcoin")
        XCTAssertEqual(rows.first?.kind, .buy)
        XCTAssertEqual(rows.first?.amount, 0.5)
        XCTAssertEqual(rows.first?.pricePerCoin, 60000)
        XCTAssertEqual(rows.last?.kind, .sell)
    }

    func test_matchesColumnsByNameNotPosition() throws {
        let rows = try CSVTransactionParser.parse("""
        type,price_per_coin,coin,amount,date
        buy,100.0,solana,3,2026-01-02
        """)

        XCTAssertEqual(rows.first?.coinID, "solana")
        XCTAssertEqual(rows.first?.amount, 3)
        XCTAssertEqual(rows.first?.pricePerCoin, 100)
    }

    func test_skipsUnusableRowsButKeepsTheRest() throws {
        let rows = try CSVTransactionParser.parse("""
        \(header)
        2026-09-15,bitcoin,buy,0.5,60000.0,30000.0,yes
        not-a-date,bitcoin,buy,1,100,100,yes
        2026-09-15,bitcoin,nonsense,1,100,100,yes
        2026-09-15,bitcoin,buy,-1,100,100,yes
        ,,,,,,
        """)

        XCTAssertEqual(rows.count, 1)
    }

    func test_acceptsCommonExchangeDateFormats() throws {
        let rows = try CSVTransactionParser.parse("""
        date,coin,type,amount,price_per_coin
        2026-09-15 13:45:00,bitcoin,buy,1,100
        09/16/2026,bitcoin,buy,1,100
        """)

        XCTAssertEqual(rows.count, 2)
    }

    func test_handlesQuotedFields() throws {
        let rows = try CSVTransactionParser.parse("""
        date,coin,type,amount,price_per_coin
        "2026-09-15","bitcoin","buy","1.5","100.25"
        """)

        XCTAssertEqual(rows.first?.amount, 1.5)
        XCTAssertEqual(rows.first?.pricePerCoin, 100.25)
    }

    func test_rejectsAFileMissingRequiredColumns() {
        XCTAssertThrowsError(try CSVTransactionParser.parse("date,coin,amount\n2026-09-15,bitcoin,1"))
    }

    func test_rejectsAFileWithNoUsableRows() {
        XCTAssertThrowsError(try CSVTransactionParser.parse("\(header)\nnope,nope,nope,nope,nope,nope,nope"))
    }
}
