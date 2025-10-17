//
//  PlanTests.swift
//  sevgilimTests

import XCTest
@testable import sevgilim

final class PlanTests: XCTestCase {
    
    func testPlanInitialization() {
        let plan = Plan(
            id: UUID().uuidString,
            relationshipId: UUID().uuidString,
            title: "Weekend Trip",
            description: "Visit mountains",
            date: Date().addingTimeInterval(86400 * 7),
            location: "Mountain Resort",
            isCompleted: false,
            userId: UUID().uuidString,
            createdAt: Date()
        )
        
        XCTAssertEqual(plan.title, "Weekend Trip")
        XCTAssertFalse(plan.isCompleted)
        XCTAssertGreaterThan(plan.date, Date())
    }
    
    func testCompletedPlan() {
        let plan = Plan(
            relationshipId: UUID().uuidString,
            title: "Done Plan",
            description: "Completed",
            date: Date(),
            location: nil,
            isCompleted: true,
            userId: UUID().uuidString,
            createdAt: Date()
        )
        
        XCTAssertTrue(plan.isCompleted)
    }
}
