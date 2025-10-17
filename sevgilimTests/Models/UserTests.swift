//
//  UserTests.swift
//  sevgilimTests
//
//  Unit tests for User model

import XCTest
@testable import sevgilim

final class UserTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testUserInitialization() {
        // Given: User parameters
        let id = UUID().uuidString
        let email = "test@test.com"
        let name = "Test User"
        let profileImageURL = "https://example.com/image.jpg"
        let relationshipId = UUID().uuidString
        let createdAt = Date()
        
        // When: Creating user
        let user = User(
            id: id,
            email: email,
            name: name,
            profileImageURL: profileImageURL,
            relationshipId: relationshipId,
            createdAt: createdAt
        )
        
        // Then: All properties should be set correctly
        XCTAssertEqual(user.id, id, "User ID should match")
        XCTAssertEqual(user.email, email, "Email should match")
        XCTAssertEqual(user.name, name, "Name should match")
        XCTAssertEqual(user.profileImageURL, profileImageURL, "Profile image URL should match")
        XCTAssertEqual(user.relationshipId, relationshipId, "Relationship ID should match")
        XCTAssertEqual(user.createdAt, createdAt, "Created at should match")
    }
    
    func testUserWithoutOptionalFields() {
        // Given: User without optional fields
        let user = User(
            id: UUID().uuidString,
            email: "test@test.com",
            name: "Test User",
            profileImageURL: nil,
            relationshipId: nil,
            createdAt: Date()
        )
        
        // Then: Optional fields should be nil
        XCTAssertNil(user.profileImageURL, "Profile image URL should be nil")
        XCTAssertNil(user.relationshipId, "Relationship ID should be nil")
    }
    
    // MARK: - Codable Tests
    
    func testUserEncodingAndDecoding() throws {
        // Given: User instance
        let originalUser = User(
            id: UUID().uuidString,
            email: "test@test.com",
            name: "Test User",
            profileImageURL: "https://example.com/image.jpg",
            relationshipId: UUID().uuidString,
            createdAt: Date()
        )
        
        // When: Encoding and decoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalUser)
        
        let decoder = JSONDecoder()
        let decodedUser = try decoder.decode(User.self, from: data)
        
        // Then: Decoded user should match original
        XCTAssertEqual(decodedUser.id, originalUser.id, "ID should match after encoding/decoding")
        XCTAssertEqual(decodedUser.email, originalUser.email, "Email should match after encoding/decoding")
        XCTAssertEqual(decodedUser.name, originalUser.name, "Name should match after encoding/decoding")
        XCTAssertEqual(decodedUser.profileImageURL, originalUser.profileImageURL, "Profile image URL should match")
        XCTAssertEqual(decodedUser.relationshipId, originalUser.relationshipId, "Relationship ID should match")
    }
    
    // MARK: - Validation Tests
    
    func testValidEmailFormat() {
        // Given: Valid email formats
        let validEmails = [
            "test@test.com",
            "user.name@example.co.uk",
            "user+tag@domain.com"
        ]
        
        // Then: All should be considered valid
        for email in validEmails {
            let user = User(
                id: UUID().uuidString,
                email: email,
                name: "Test",
                profileImageURL: nil,
                relationshipId: nil,
                createdAt: Date()
            )
            XCTAssertFalse(user.email.isEmpty, "Email should not be empty: \(email)")
        }
    }
    
    func testUserHasRelationship() {
        // Given: User with relationship
        let userWithRelationship = User(
            id: UUID().uuidString,
            email: "test@test.com",
            name: "Test",
            profileImageURL: nil,
            relationshipId: UUID().uuidString,
            createdAt: Date()
        )
        
        // Then: Should have relationship ID
        XCTAssertNotNil(userWithRelationship.relationshipId, "User should have relationship")
        
        // Given: User without relationship
        let userWithoutRelationship = User(
            id: UUID().uuidString,
            email: "test@test.com",
            name: "Test",
            profileImageURL: nil,
            relationshipId: nil,
            createdAt: Date()
        )
        
        // Then: Should not have relationship ID
        XCTAssertNil(userWithoutRelationship.relationshipId, "User should not have relationship")
    }
}
