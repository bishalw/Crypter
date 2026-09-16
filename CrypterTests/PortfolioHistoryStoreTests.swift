//
//  PortfolioHistoryStoreTests.swift
//  CrypterTests
//

import XCTest
@testable import Crypter

final class PortfolioHistoryStoreTests: XCTestCase {

    private var defaults: UserDefaults!
    private var sut: PortfolioHistoryStore!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "PortfolioHistoryStoreTests")!
        defaults.removePersistentDomain(forName: "PortfolioHistoryStoreTests")
        sut = PortfolioHistoryStore(defaults: defaults, storageKey: "history")
    }

    private func day(_ offset: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: offset, to: Date())!
    }

    func test_recordingTwiceInADayKeepsOnlyTheLatest() {
        sut.record(value: 100, on: day(0))
        sut.record(value: 150, on: day(0))

        XCTAssertEqual(sut.snapshots.count, 1)
        XCTAssertEqual(sut.snapshots.first?.value, 150)
    }

    func test_snapshotsAreKeptInDateOrder() {
        sut.record(value: 300, on: day(-1))
        sut.record(value: 100, on: day(-3))
        sut.record(value: 200, on: day(-2))

        XCTAssertEqual(sut.snapshots.map(\.value), [100, 200, 300])
    }

    func test_zeroIsNotRecorded() {
        sut.record(value: 0, on: day(0))

        XCTAssertTrue(sut.snapshots.isEmpty)
    }

    func test_changeIsMeasuredAcrossTheWindow() throws {
        sut.record(value: 100, on: day(-5))
        sut.record(value: 125, on: day(0))

        let change = try XCTUnwrap(sut.change(withinLast: 30))

        XCTAssertEqual(change.amount, 25, accuracy: 0.0001)
        XCTAssertEqual(change.percent, 25, accuracy: 0.0001)
    }

    func test_changeNeedsTwoPointsInTheWindow() {
        sut.record(value: 100, on: day(-40))
        sut.record(value: 200, on: day(0))

        XCTAssertNil(sut.change(withinLast: 7))
    }

    func test_windowExcludesOlderSnapshots() {
        sut.record(value: 100, on: day(-40))
        sut.record(value: 200, on: day(-1))

        XCTAssertEqual(sut.snapshots(withinLast: 7).count, 1)
    }

    func test_snapshotsSurviveANewInstance() {
        sut.record(value: 100, on: day(-1))

        let reloaded = PortfolioHistoryStore(defaults: defaults, storageKey: "history")

        XCTAssertEqual(reloaded.snapshots.map(\.value), [100])
    }
}
