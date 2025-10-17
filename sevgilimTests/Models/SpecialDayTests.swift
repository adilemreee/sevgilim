//
//  SpecialDayTests.swift
//  sevgilimTests

import XCTest
@testable import sevgilim

final class SpecialDayTests: XCTestCase {
    
    func testSpecialDayInitialization() {
        let specialDay = SpecialDay(
            id: UUID().uuidString,
            relationshipId: UUID().uuidString,
            title: "Anniversary",
            date: Date(),
            description: "Our first year",
            isRecurring: true,
            userId: UUID().uuidString,
            createdAt: Date()
        )
        
        XCTAssertEqual(specialDay.title, "Anniversary")
        XCTAssertTrue(specialDay.isRecurring)
        XCTAssertNotNil(specialDay.description)
    }
    
    func testNonRecurringDay() {
        let specialDay = SpecialDay(
            relationshipId: UUID().uuidString,
            title: "One Time Event",
            date: Date(),
            description: nil,
            isRecurring: false,
            userId: UUID().uuidString,
            createdAt: Date()
        )
        
        XCTAssertFalse(specialDay.isRecurring)
    }
}
