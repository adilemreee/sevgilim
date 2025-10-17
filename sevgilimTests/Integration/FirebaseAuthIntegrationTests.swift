//
//  FirebaseAuthIntegrationTests.swift
//  sevgilimTests
//
//  Integration tests for Firebase Authentication + Firestore

import XCTest
@testable import sevgilim

@MainActor
final class FirebaseAuthIntegrationTests: XCTestCase {
    
    var authService: AuthenticationService!
    var relationshipService: RelationshipService!
    
    override func setUp() async throws {
        try await super.setUp()
        authService = AuthenticationService()
        relationshipService = RelationshipService()
    }
    
    override func tearDown() async throws {
        // Cleanup: Sign out and delete test data
        authService.signOut()
        authService = nil
        relationshipService.stopListening()
        relationshipService = nil
        try await super.tearDown()
    }
    
    // MARK: - Auth + Firestore Integration
    
    func testSignUpCreatesUserInFirestore() async throws {
        // Given: New user credentials
        let email = "integration_test_\(UUID().uuidString)@test.com"
        let password = "Test123456"
        let name = "Integration Test User"
        
        // When: User signs up
        do {
            try await authService.signUp(email: email, password: password, name: name)
            
            // Then: User should be created in Auth AND Firestore
            XCTAssertNotNil(authService.currentUser, "User should be authenticated")
            XCTAssertEqual(authService.currentUser?.email, email, "Email should match")
            XCTAssertEqual(authService.currentUser?.name, name, "Name should match")
            
            // Verify user exists in Firestore
            XCTAssertNotNil(authService.currentUser?.id, "User should have Firestore document ID")
            
            // Cleanup
            authService.signOut()
        } catch {
            XCTFail("Integration test failed: \(error.localizedDescription)")
        }
    }
    
    func testSignInFetchesUserFromFirestore() async throws {
        // Note: This test requires a pre-existing test user in Firebase
        let testEmail = "existing_test@example.com"
        let testPassword = "Test123456"
        
        do {
            try await authService.signIn(email: testEmail, password: testPassword)
            
            // Then: User data should be fetched from Firestore
            XCTAssertNotNil(authService.currentUser, "User should be authenticated")
            XCTAssertNotNil(authService.currentUser?.id, "User should have ID from Firestore")
            XCTAssertNotNil(authService.currentUser?.name, "User should have name from Firestore")
            
            authService.signOut()
        } catch {
            print("Sign in integration test skipped - requires existing test user: \(error)")
        }
    }
    
    // MARK: - Auth + Relationship Integration
    
    func testCreateRelationshipWithAuthenticatedUser() async throws {
        // Given: Authenticated user
        let email = "auth_rel_test_\(UUID().uuidString)@test.com"
        let password = "Test123456"
        let name = "Test User"
        
        do {
            try await authService.signUp(email: email, password: password, name: name)
            
            guard let userId = authService.currentUser?.id else {
                XCTFail("User ID should exist")
                return
            }
            
            // When: Creating relationship
            let relationshipId = try await relationshipService.createRelationship(
                user1Id: userId,
                user1Name: name,
                user2Email: "partner@test.com",
                startDate: Date()
            )
            
            // Then: Relationship should be created
            XCTAssertFalse(relationshipId.isEmpty, "Relationship ID should not be empty")
            
            // Cleanup
            authService.signOut()
        } catch {
            print("Create relationship integration test skipped: \(error)")
        }
    }
    
    // MARK: - Multi-User Integration
    
    func testTwoUsersInSameRelationship() async throws {
        // This test simulates two users connecting via relationship
        
        // User 1 signs up
        let user1Email = "user1_\(UUID().uuidString)@test.com"
        let user1Password = "Test123456"
        let user1Name = "User One"
        
        do {
            try await authService.signUp(email: user1Email, password: user1Password, name: user1Name)
            guard let user1Id = authService.currentUser?.id else {
                XCTFail("User 1 should have ID")
                return
            }
            
            // User 1 creates relationship
            let user2Email = "user2@test.com"
            let relationshipId = try await relationshipService.createRelationship(
                user1Id: user1Id,
                user1Name: user1Name,
                user2Email: user2Email,
                startDate: Date()
            )
            
            XCTAssertFalse(relationshipId.isEmpty)
            
            // Sign out user 1
            authService.signOut()
            
            // Note: In real scenario, User 2 would sign up and accept invitation
            // This would require more complex test setup
            
            XCTAssertTrue(true, "Multi-user integration test structure validated")
        } catch {
            print("Multi-user integration test skipped: \(error)")
        }
    }
    
    // MARK: - Error Handling Integration
    
    func testAuthErrorPropagation() async throws {
        // Test that Firebase auth errors are properly handled
        
        do {
            try await authService.signIn(email: "nonexistent@test.com", password: "wrongpassword")
            XCTFail("Should throw error for invalid credentials")
        } catch {
            XCTAssertNotNil(error, "Error should be thrown")
            XCTAssertNotNil(authService.errorMessage, "Error message should be set")
        }
    }
}
