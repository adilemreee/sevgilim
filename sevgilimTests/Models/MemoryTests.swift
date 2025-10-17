//
//  MemoryTests.swift
//  sevgilimTests
//
//  Unit tests for Memory model

import XCTest
@testable import sevgilim

final class MemoryTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testMemoryInitialization() {
        // Given: Memory parameters
        let id = UUID().uuidString
        let relationshipId = UUID().uuidString
        let title = "Beautiful Day"
        let content = "We had an amazing time today!"
        let date = Date()
        let photoURL = "https://example.com/photo.jpg"
        let location = "Paris, France"
        let tags = ["vacation", "romantic"]
        let userId = UUID().uuidString
        let createdAt = Date()
        let likes = [UUID().uuidString]
        let comments = [
            Comment(userId: UUID().uuidString, userName: "User", text: "Great!", createdAt: Date())
        ]
        
        // When: Creating memory
        let memory = Memory(
            id: id,
            relationshipId: relationshipId,
            title: title,
            content: content,
            date: date,
            photoURL: photoURL,
            location: location,
            tags: tags,
            userId: userId,
            createdAt: createdAt,
            likes: likes,
            comments: comments
        )
        
        // Then: All properties should be set correctly
        XCTAssertEqual(memory.id, id, "Memory ID should match")
        XCTAssertEqual(memory.relationshipId, relationshipId, "Relationship ID should match")
        XCTAssertEqual(memory.title, title, "Title should match")
        XCTAssertEqual(memory.content, content, "Content should match")
        XCTAssertEqual(memory.date, date, "Date should match")
        XCTAssertEqual(memory.photoURL, photoURL, "Photo URL should match")
        XCTAssertEqual(memory.location, location, "Location should match")
        XCTAssertEqual(memory.tags, tags, "Tags should match")
        XCTAssertEqual(memory.userId, userId, "User ID should match")
        XCTAssertEqual(memory.createdAt, createdAt, "Created at should match")
        XCTAssertEqual(memory.likes, likes, "Likes should match")
        XCTAssertEqual(memory.comments.count, 1, "Should have 1 comment")
    }
    
    func testMemoryWithoutOptionalFields() {
        // Given: Memory without optional fields
        let memory = Memory(
            relationshipId: UUID().uuidString,
            title: "Test Memory",
            content: "Content",
            date: Date(),
            photoURL: nil,
            location: nil,
            tags: nil,
            userId: UUID().uuidString,
            createdAt: Date(),
            likes: [],
            comments: []
        )
        
        // Then: Optional fields should be nil or empty
        XCTAssertNil(memory.photoURL, "Photo URL should be nil")
        XCTAssertNil(memory.location, "Location should be nil")
        XCTAssertNil(memory.tags, "Tags should be nil")
        XCTAssertTrue(memory.likes.isEmpty, "Likes should be empty")
        XCTAssertTrue(memory.comments.isEmpty, "Comments should be empty")
    }
    
    // MARK: - Likes Tests
    
    func testMemoryLikesCount() {
        // Given: Memory with likes
        let memory = Memory(
            relationshipId: UUID().uuidString,
            title: "Test",
            content: "Content",
            date: Date(),
            photoURL: nil,
            location: nil,
            tags: nil,
            userId: UUID().uuidString,
            createdAt: Date(),
            likes: ["user1", "user2", "user3"],
            comments: []
        )
        
        // Then: Likes count should be correct
        XCTAssertEqual(memory.likes.count, 3, "Should have 3 likes")
    }
    
    func testMemoryIsLikedByUser() {
        // Given: Memory and user ID
        let userId = UUID().uuidString
        let memory = Memory(
            relationshipId: UUID().uuidString,
            title: "Test",
            content: "Content",
            date: Date(),
            photoURL: nil,
            location: nil,
            tags: nil,
            userId: UUID().uuidString,
            createdAt: Date(),
            likes: [userId],
            comments: []
        )
        
        // Then: Should contain user ID
        XCTAssertTrue(memory.likes.contains(userId), "Memory should be liked by user")
    }
    
    // MARK: - Comments Tests
    
    func testMemoryCommentsCount() {
        // Given: Memory with comments
        let comments = [
            Comment(userId: "1", userName: "User 1", text: "Nice!", createdAt: Date()),
            Comment(userId: "2", userName: "User 2", text: "Love it!", createdAt: Date())
        ]
        let memory = Memory(
            relationshipId: UUID().uuidString,
            title: "Test",
            content: "Content",
            date: Date(),
            photoURL: nil,
            location: nil,
            tags: nil,
            userId: UUID().uuidString,
            createdAt: Date(),
            likes: [],
            comments: comments
        )
        
        // Then: Comments count should be correct
        XCTAssertEqual(memory.comments.count, 2, "Should have 2 comments")
    }
    
    // MARK: - Tags Tests
    
    func testMemoryWithTags() {
        // Given: Memory with tags
        let tags = ["vacation", "beach", "summer"]
        let memory = Memory(
            relationshipId: UUID().uuidString,
            title: "Beach Day",
            content: "Amazing beach vacation",
            date: Date(),
            photoURL: nil,
            location: nil,
            tags: tags,
            userId: UUID().uuidString,
            createdAt: Date(),
            likes: [],
            comments: []
        )
        
        // Then: Tags should be set correctly
        XCTAssertEqual(memory.tags?.count, 3, "Should have 3 tags")
        XCTAssertTrue(memory.tags?.contains("vacation") ?? false, "Should contain vacation tag")
    }
    
    // MARK: - Date Tests
    
    func testMemoryDateIsPastOrPresent() {
        // Given: Memory with past date
        let pastDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        let memory = Memory(
            relationshipId: UUID().uuidString,
            title: "Old Memory",
            content: "From the past",
            date: pastDate,
            photoURL: nil,
            location: nil,
            tags: nil,
            userId: UUID().uuidString,
            createdAt: Date(),
            likes: [],
            comments: []
        )
        
        // Then: Date should be in the past
        XCTAssertLessThanOrEqual(memory.date, Date(), "Memory date should be in past or present")
    }
}
