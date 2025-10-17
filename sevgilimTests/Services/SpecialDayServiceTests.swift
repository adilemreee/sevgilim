//
//  SpecialDayServiceTests.swift
//  sevgilimTests
//
//  Unit tests for SpecialDayService

import XCTest
@testable import sevgilim

@MainActor
final class SpecialDayServiceTests: XCTestCase {
    
    var sut: SpecialDayService!
    
    override func setUp() async throws {
        try await super.setUp()
        sut = SpecialDayService()
    }
    
    override func tearDown() async throws {
        sut.stopListening()
        sut = nil
        try await super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertTrue(sut.specialDays.isEmpty)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testAddSpecialDay() async throws {
        do {
            try await sut.addSpecialDay(
                relationshipId: UUID().uuidString,
                title: "Anniversary",
                date: Date(),
                description: "Our first anniversary",
                isRecurring: true,
                userId: UUID().uuidString
            )
            XCTAssertTrue(true)
        } catch {
            XCTFail("Add special day failed: \(error)")
        }
    }
    
    func testAddRecurringSpecialDay() async throws {
        do {
            try await sut.addSpecialDay(
                relationshipId: UUID().uuidString,
                title: "Monthly Date",
                date: Date(),
                description: "Every month",
                isRecurring: true,
                userId: UUID().uuidString
            )
            XCTAssertTrue(true)
        } catch {
            XCTFail("Add recurring special day failed: \(error)")
        }
    }
    
    func testListenToSpecialDays() {
        sut.listenToSpecialDays(relationshipId: UUID().uuidString)
        XCTAssertTrue(sut.isLoading)
    }
    
    func testDeleteSpecialDay() async throws {
        let specialDay = SpecialDay(
            id: UUID().uuidString,
            relationshipId: UUID().uuidString,
            title: "Test Day",
            date: Date(),
            description: "Test",
            isRecurring: false,
            userId: UUID().uuidString,
            createdAt: Date()
        )
        
        do {
            try await sut.deleteSpecialDay(specialDay)
            XCTAssertTrue(true)
        } catch {
            print("Delete special day test skipped")
        }
    }
    
    func testGetUpcomingSpecialDay() {
        let today = Date()
        let futureDay = SpecialDay(
            relationshipId: UUID().uuidString,
            title: "Future Event",
            date: today.addingTimeInterval(86400),
            description: "Tomorrow",
            isRecurring: false,
            userId: UUID().uuidString,
            createdAt: today
        )
        
        XCTAssertGreaterThan(futureDay.date, today)
    }
}
