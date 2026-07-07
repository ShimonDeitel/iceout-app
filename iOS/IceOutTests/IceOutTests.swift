import XCTest
@testable import IceOut

@MainActor
final class IceOutTests: XCTestCase {
    var store: Store!

    override func setUp() async throws {
        store = Store()
    }

    func testSeedDataLoadsBelowFreeLimit() {
        XCTAssertLessThan(store.entries.count, Store.freeTierLimit)
    }

    func testAddEntryIncreasesCount() {
        let before = store.entries.count
        store.add(IceEvent(bodyName: "Test Entry"))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testAddedEntryAppearsFirst() {
        store.add(IceEvent(bodyName: "Newest"))
        XCTAssertEqual(store.entries.first?.bodyName, "Newest")
    }

    func testDeleteRemovesEntry() {
        let entry = IceEvent(bodyName: "ToDelete")
        store.add(entry)
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(entry))
    }

    func testCanAddMoreWhenBelowLimit() {
        XCTAssertTrue(store.canAddMore)
    }

    func testCannotAddMoreAtFreeLimitWithoutPro() {
        store.entries = (0..<Store.freeTierLimit).map { _ in IceEvent(bodyName: "X") }
        XCTAssertFalse(store.canAddMore)
    }

    func testAddBlockedAtLimitDoesNotAppend() {
        store.entries = (0..<Store.freeTierLimit).map { _ in IceEvent(bodyName: "X") }
        let before = store.entries.count
        store.add(IceEvent(bodyName: "Overflow"))
        XCTAssertEqual(store.entries.count, before)
    }

    func testUpdateModifiesExistingEntry() {
        let entry = IceEvent(bodyName: "Original")
        store.add(entry)
        var updated = entry
        updated.bodyName = "Updated"
        store.update(updated)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.bodyName, "Updated")
    }
}
