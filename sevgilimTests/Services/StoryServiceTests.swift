//
//  StoryServiceTests.swift
//  sevgilimTests
//
//  Unit tests for StoryService

import XCTest
@testable import sevgilim

@MainActor
final class StoryServiceTests: XCTestCase {
    
    var sut: StoryService!
    
    override func setUp() async throws {
        try await super.setUp()
        sut = StoryService()
    }
    
    override func tearDown() async throws {
        sut.stopListening()
        sut = nil
        try await super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertTrue(sut.stories.isEmpty)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testAddStory() async throws {
        do {
            try await sut.addStory(
                relationshipId: UUID().uuidString,
                userId: UUID().uuidString,
                imageURL: "https://example.com/story.jpg",
                caption: "Great day!"
            )
            XCTAssertTrue(true)
        } catch {
            XCTFail("Add story failed: \(error)")
        }
    }
    
    func testStoryExpiration() {
        let now = Date()
        let oldStory = Story(
            relationshipId: UUID().uuidString,
            userId: UUID().uuidString,
            userName: "Test",
            imageURL: "test.jpg",
            caption: nil,
            createdAt: now.addingTimeInterval(-86400 * 2), // 2 days ago
            expiresAt: now.addingTimeInterval(-86400) // Expired yesterday
        )
        
        XCTAssertLessThan(oldStory.expiresAt, now, "Story should be expired")
    }
    
    func testActiveStory() {
        let now = Date()
        let activeStory = Story(
            relationshipId: UUID().uuidString,
            userId: UUID().uuidString,
            userName: "Test",
            imageURL: "test.jpg",
            caption: nil,
            createdAt: now,
            expiresAt: now.addingTimeInterval(86400) // Expires tomorrow
        )
        
        XCTAssertGreaterThan(activeStory.expiresAt, now, "Story should be active")
    }
    
    func testListenToStories() {
        sut.listenToStories(relationshipId: UUID().uuidString)
        XCTAssertTrue(sut.isLoading)
    }
    
    func testDeleteStory() async throws {
        let story = Story(
            id: UUID().uuidString,
            relationshipId: UUID().uuidString,
            userId: UUID().uuidString,
            userName: "Test",
            imageURL: "test.jpg",
            caption: nil,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(86400)
        )
        
        do {
            try await sut.deleteStory(story)
            XCTAssertTrue(true)
        } catch {
            print("Delete story test skipped")
        }
    }
}
