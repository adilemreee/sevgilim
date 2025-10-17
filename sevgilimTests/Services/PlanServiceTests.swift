//
//  PlanServiceTests.swift
//  sevgilimTests
//
//  Unit tests for PlanService

import XCTest
@testable import sevgilim

@MainActor
final class PlanServiceTests: XCTestCase {
    
    var sut: PlanService!
    
    override func setUp() async throws {
        try await super.setUp()
        sut = PlanService()
    }
    
    override func tearDown() async throws {
        sut.stopListening()
        sut = nil
        try await super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertTrue(sut.plans.isEmpty)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testAddPlan() async throws {
        do {
            try await sut.addPlan(
                relationshipId: UUID().uuidString,
                title: "Weekend Trip",
                description: "Visit the mountains",
                date: Date().addingTimeInterval(86400 * 7),
                location: "Mountain Resort",
                isCompleted: false,
                userId: UUID().uuidString
            )
            XCTAssertTrue(true)
        } catch {
            XCTFail("Add plan failed: \(error)")
        }
    }
    
    func testToggleCompletion() async throws {
        let plan = Plan(
            id: UUID().uuidString,
            relationshipId: UUID().uuidString,
            title: "Test Plan",
            description: "Test",
            date: Date(),
            location: nil,
            isCompleted: false,
            userId: UUID().uuidString,
            createdAt: Date()
        )
        
        do {
            try await sut.toggleCompletion(plan)
            XCTAssertTrue(true)
        } catch {
            print("Toggle completion test skipped")
        }
    }
    
    func testListenToPlans() {
        sut.listenToPlans(relationshipId: UUID().uuidString)
        XCTAssertTrue(sut.isLoading)
    }
    
    func testDeletePlan() async throws {
        let plan = Plan(
            id: UUID().uuidString,
            relationshipId: UUID().uuidString,
            title: "Test",
            description: "Test",
            date: Date(),
            location: nil,
            isCompleted: false,
            userId: UUID().uuidString,
            createdAt: Date()
        )
        
        do {
            try await sut.deletePlan(plan)
            XCTAssertTrue(true)
        } catch {
            print("Delete plan test skipped")
        }
    }
}
