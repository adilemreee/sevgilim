//
//  StoryTests.swift
//  sevgilimTests

import XCTest
@testable import sevgilim

final class StoryTests: XCTestCase {
    
    func testStoryInitialization() {
        let story = Story(
            id: UUID().uuidString,
            relationshipId: UUID().uuidString,
            userId: UUID().uuidString,
            userName: "Test User",
            imageURL: "https://example.com/story.jpg",
            caption: "Great day!",
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(86400)
        )
        
        XCTAssertEqual(story.userName, "Test User")
        XCTAssertNotNil(story.caption)
        XCTAssertGreaterThan(story.expiresAt, story.createdAt)
    }
    
    func testExpiredStory() {
        let story = Story(
            relationshipId: UUID().uuidString,
            userId: UUID().uuidString,
            userName: "Test",
            imageURL: "test.jpg",
            caption: nil,
            createdAt: Date().addingTimeInterval(-86400 * 2),
            expiresAt: Date().addingTimeInterval(-86400)
        )
        
        XCTAssertLessThan(story.expiresAt, Date())
    }
    
    func testActiveStory() {
        let story = Story(
            relationshipId: UUID().uuidString,
            userId: UUID().uuidString,
            userName: "Test",
            imageURL: "test.jpg",
            caption: nil,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(86400)
        )
        
        XCTAssertGreaterThan(story.expiresAt, Date())
    }
}
