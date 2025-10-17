//
//  SurpriseTests.swift
//  sevgilimTests
//
//  Unit tests for Surprise model

import XCTest
@testable import sevgilim

final class SurpriseTests: XCTestCase {
    
    func testSurpriseInitialization() {
        let id = UUID().uuidString
        let relationshipId = UUID().uuidString
        let creatorId = UUID().uuidString
        let title = "Romantic Dinner"
        let message = "Surprise!"
        let unlockDate = Date().addingTimeInterval(86400)
        let imageURL = "https://example.com/surprise.jpg"
        let location = "Restaurant"
        let isUnlocked = false
        let unlockedAt: Date? = nil
        
        let surprise = Surprise(
            id: id,
            relationshipId: relationshipId,
            creatorId: creatorId,
            title: title,
            message: message,
            unlockDate: unlockDate,
            imageURL: imageURL,
            location: location,
            isUnlocked: isUnlocked,
            unlockedAt: unlockedAt
        )
        
        XCTAssertEqual(surprise.id, id)
        XCTAssertEqual(surprise.title, title)
        XCTAssertEqual(surprise.message, message)
        XCTAssertFalse(surprise.isUnlocked)
        XCTAssertNil(surprise.unlockedAt)
    }
    
    func testLockedSurprise() {
        let surprise = Surprise(
            relationshipId: UUID().uuidString,
            creatorId: UUID().uuidString,
            title: "Future Surprise",
            message: "Wait for it!",
            unlockDate: Date().addingTimeInterval(86400),
            imageURL: nil,
            location: nil,
            isUnlocked: false,
            unlockedAt: nil
        )
        
        XCTAssertFalse(surprise.isUnlocked)
        XCTAssertGreaterThan(surprise.unlockDate, Date())
    }
    
    func testUnlockedSurprise() {
        let surprise = Surprise(
            relationshipId: UUID().uuidString,
            creatorId: UUID().uuidString,
            title: "Revealed Surprise",
            message: "Surprise!",
            unlockDate: Date().addingTimeInterval(-86400),
            imageURL: nil,
            location: nil,
            isUnlocked: true,
            unlockedAt: Date()
        )
        
        XCTAssertTrue(surprise.isUnlocked)
        XCTAssertNotNil(surprise.unlockedAt)
    }
}
