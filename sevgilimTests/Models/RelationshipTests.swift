//
//  RelationshipTests.swift
//  sevgilimTests

import XCTest
@testable import sevgilim

final class RelationshipTests: XCTestCase {
    
    func testRelationshipInitialization() {
        let relationship = Relationship(
            id: UUID().uuidString,
            user1Id: UUID().uuidString,
            user1Name: "User 1",
            user2Id: UUID().uuidString,
            user2Name: "User 2",
            startDate: Date(),
            createdAt: Date()
        )
        
        XCTAssertEqual(relationship.user1Name, "User 1")
        XCTAssertEqual(relationship.user2Name, "User 2")
        XCTAssertNotNil(relationship.startDate)
    }
    
    func testRelationshipDuration() {
        let startDate = Calendar.current.date(byAdding: .day, value: -100, to: Date())!
        let relationship = Relationship(
            id: UUID().uuidString,
            user1Id: UUID().uuidString,
            user1Name: "User 1",
            user2Id: UUID().uuidString,
            user2Name: "User 2",
            startDate: startDate,
            createdAt: Date()
        )
        
        let days = startDate.daysBetween(Date())
        XCTAssertGreaterThanOrEqual(days, 99)
        XCTAssertLessThanOrEqual(days, 101)
    }
}
