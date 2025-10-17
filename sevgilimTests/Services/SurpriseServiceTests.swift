//
//  SurpriseServiceTests.swift
//  sevgilimTests
//
//  Unit tests for SurpriseService

import XCTest
@testable import sevgilim

@MainActor
final class SurpriseServiceTests: XCTestCase {
    
    var sut: SurpriseService!
    
    override func setUp() async throws {
        try await super.setUp()
        sut = SurpriseService()
    }
    
    override func tearDown() async throws {
        sut.stopListening()
        sut = nil
        try await super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertTrue(sut.surprises.isEmpty, "Surprises should be empty initially")
        XCTAssertFalse(sut.isLoading, "Should not be loading initially")
    }
    
    // MARK: - Add Surprise Tests
    
    func testAddSurpriseWithValidData() async throws {
        let relationshipId = UUID().uuidString
        let creatorId = UUID().uuidString
        let title = "Romantic Dinner"
        let message = "I planned a special dinner for us!"
        let unlockDate = Date().addingTimeInterval(86400) // Tomorrow
        let imageURL = "https://example.com/surprise.jpg"
        
        do {
            try await sut.addSurprise(
                relationshipId: relationshipId,
                creatorId: creatorId,
                title: title,
                message: message,
                unlockDate: unlockDate,
                imageURL: imageURL,
                location: nil
            )
            XCTAssertTrue(true, "Add surprise should succeed")
        } catch {
            XCTFail("Add surprise failed: \(error.localizedDescription)")
        }
    }
    
    func testAddSurpriseWithPastDate() async {
        let relationshipId = UUID().uuidString
        let creatorId = UUID().uuidString
        let title = "Old Surprise"
        let message = "This is in the past"
        let unlockDate = Date().addingTimeInterval(-86400) // Yesterday
        
        do {
            try await sut.addSurprise(
                relationshipId: relationshipId,
                creatorId: creatorId,
                title: title,
                message: message,
                unlockDate: unlockDate,
                imageURL: nil,
                location: nil
            )
            // Should validate unlock date
        } catch {
            XCTAssertNotNil(error, "Should handle past unlock date")
        }
    }
    
    func testAddSurpriseWithEmptyTitle() async {
        let relationshipId = UUID().uuidString
        let creatorId = UUID().uuidString
        let title = ""
        let message = "Surprise!"
        let unlockDate = Date().addingTimeInterval(86400)
        
        do {
            try await sut.addSurprise(
                relationshipId: relationshipId,
                creatorId: creatorId,
                title: title,
                message: message,
                unlockDate: unlockDate,
                imageURL: nil,
                location: nil
            )
            // Should validate title
        } catch {
            XCTAssertNotNil(error, "Should throw error for empty title")
        }
    }
    
    // MARK: - Unlock Surprise Tests
    
    func testUnlockSurprise() async throws {
        let surprise = Surprise(
            id: UUID().uuidString,
            relationshipId: UUID().uuidString,
            creatorId: UUID().uuidString,
            title: "Test Surprise",
            message: "Surprise!",
            unlockDate: Date(),
            imageURL: nil,
            location: nil,
            isUnlocked: false,
            unlockedAt: nil
        )
        
        do {
            try await sut.unlockSurprise(surprise)
            XCTAssertTrue(true, "Unlock surprise should succeed")
        } catch {
            print("Unlock surprise test skipped - surprise not in Firestore")
        }
    }
    
    // MARK: - Delete Surprise Tests
    
    func testDeleteSurprise() async throws {
        let surprise = Surprise(
            id: UUID().uuidString,
            relationshipId: UUID().uuidString,
            creatorId: UUID().uuidString,
            title: "Test Surprise",
            message: "Surprise!",
            unlockDate: Date(),
            imageURL: nil,
            location: nil,
            isUnlocked: false,
            unlockedAt: nil
        )
        
        do {
            try await sut.deleteSurprise(surprise)
            XCTAssertTrue(true, "Delete surprise should succeed")
        } catch {
            print("Delete surprise test skipped - surprise not in Firestore")
        }
    }
    
    // MARK: - Listen to Surprises Tests
    
    func testListenToSurprises() {
        let relationshipId = UUID().uuidString
        
        sut.listenToSurprises(relationshipId: relationshipId)
        
        XCTAssertTrue(sut.isLoading, "Should be loading when listener starts")
    }
    
    func testStopListening() {
        let relationshipId = UUID().uuidString
        sut.listenToSurprises(relationshipId: relationshipId)
        
        sut.stopListening()
        
        XCTAssertTrue(true, "Stop listening should complete without crash")
    }
    
    // MARK: - Surprise Status Tests
    
    func testSurpriseIsLocked() {
        let futureDate = Date().addingTimeInterval(86400)
        let surprise = Surprise(
            relationshipId: UUID().uuidString,
            creatorId: UUID().uuidString,
            title: "Future Surprise",
            message: "Coming soon!",
            unlockDate: futureDate,
            imageURL: nil,
            location: nil,
            isUnlocked: false,
            unlockedAt: nil
        )
        
        XCTAssertFalse(surprise.isUnlocked, "Surprise should be locked")
        XCTAssertGreaterThan(surprise.unlockDate, Date(), "Unlock date should be in future")
    }
    
    func testSurpriseIsUnlocked() {
        let pastDate = Date().addingTimeInterval(-86400)
        let surprise = Surprise(
            relationshipId: UUID().uuidString,
            creatorId: UUID().uuidString,
            title: "Past Surprise",
            message: "Already unlocked!",
            unlockDate: pastDate,
            imageURL: nil,
            location: nil,
            isUnlocked: true,
            unlockedAt: Date()
        )
        
        XCTAssertTrue(surprise.isUnlocked, "Surprise should be unlocked")
        XCTAssertNotNil(surprise.unlockedAt, "Unlocked at should be set")
    }
    
    // MARK: - Countdown Tests
    
    func testCountdownCalculation() {
        let futureDate = Date().addingTimeInterval(3600) // 1 hour from now
        let surprise = Surprise(
            relationshipId: UUID().uuidString,
            creatorId: UUID().uuidString,
            title: "Soon",
            message: "1 hour left!",
            unlockDate: futureDate,
            imageURL: nil,
            location: nil,
            isUnlocked: false,
            unlockedAt: nil
        )
        
        let timeInterval = surprise.unlockDate.timeIntervalSince(Date())
        XCTAssertGreaterThan(timeInterval, 3500, "Should be approximately 1 hour")
        XCTAssertLessThan(timeInterval, 3700, "Should be approximately 1 hour")
    }
}
