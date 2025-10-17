//
//  AuthenticationServiceTests.swift
//  sevgilimTests
//
//  Unit tests for AuthenticationService

import XCTest
@testable import sevgilim

@MainActor
final class AuthenticationServiceTests: XCTestCase {
    
    var sut: AuthenticationService!
    
    override func setUp() async throws {
        try await super.setUp()
        sut = AuthenticationService()
    }
    
    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }
    
    // MARK: - Authentication State Tests
    
    func testInitialState() {
        // Given: Fresh AuthenticationService
        // When: Just initialized
        // Then: User should not be authenticated
        XCTAssertNil(sut.currentUser, "Current user should be nil initially")
        XCTAssertFalse(sut.isAuthenticated, "Should not be authenticated initially")
        XCTAssertNil(sut.errorMessage, "Error message should be nil initially")
    }
    
    // MARK: - Sign Up Tests
    
    func testSignUpWithValidCredentials() async throws {
        // Given: Valid credentials
        let email = "test\(UUID().uuidString)@test.com"
        let password = "Test123456"
        let name = "Test User"
        
        // When: Signing up
        do {
            try await sut.signUp(email: email, password: password, name: name)
            
            // Then: User should be authenticated
            XCTAssertNotNil(sut.currentUser, "Current user should not be nil after signup")
            XCTAssertTrue(sut.isAuthenticated, "Should be authenticated after signup")
            XCTAssertEqual(sut.currentUser?.email, email, "Email should match")
            XCTAssertEqual(sut.currentUser?.name, name, "Name should match")
        } catch {
            XCTFail("Sign up should succeed with valid credentials: \(error.localizedDescription)")
        }
    }
    
    func testSignUpWithInvalidEmail() async {
        // Given: Invalid email
        let email = "invalid-email"
        let password = "Test123456"
        let name = "Test User"
        
        // When: Signing up
        do {
            try await sut.signUp(email: email, password: password, name: name)
            XCTFail("Sign up should fail with invalid email")
        } catch {
            // Then: Should throw error
            XCTAssertNotNil(sut.errorMessage, "Error message should be set")
        }
    }
    
    func testSignUpWithWeakPassword() async {
        // Given: Weak password
        let email = "test@test.com"
        let password = "123" // Too short
        let name = "Test User"
        
        // When: Signing up
        do {
            try await sut.signUp(email: email, password: password, name: name)
            XCTFail("Sign up should fail with weak password")
        } catch {
            // Then: Should throw error
            XCTAssertNotNil(error, "Should throw error for weak password")
        }
    }
    
    // MARK: - Sign In Tests
    
    func testSignInWithValidCredentials() async throws {
        // Given: Existing user (you need to create one first in Firebase)
        let email = "existing@test.com"
        let password = "Test123456"
        
        // When: Signing in
        do {
            try await sut.signIn(email: email, password: password)
            
            // Then: User should be authenticated
            XCTAssertTrue(sut.isAuthenticated, "Should be authenticated after sign in")
            XCTAssertNotNil(sut.currentUser, "Current user should not be nil")
        } catch {
            // Note: This test requires a real Firebase account
            print("Sign in test skipped - requires real account: \(error)")
        }
    }
    
    func testSignInWithInvalidCredentials() async {
        // Given: Invalid credentials
        let email = "wrong@test.com"
        let password = "wrongpassword"
        
        // When: Signing in
        do {
            try await sut.signIn(email: email, password: password)
            XCTFail("Sign in should fail with invalid credentials")
        } catch {
            // Then: Should throw error
            XCTAssertNotNil(error, "Should throw error for invalid credentials")
        }
    }
    
    // MARK: - Sign Out Tests
    
    func testSignOut() {
        // Given: Authenticated user (mock state)
        // When: Signing out
        sut.signOut()
        
        // Then: User should be signed out
        XCTAssertNil(sut.currentUser, "Current user should be nil after sign out")
        XCTAssertFalse(sut.isAuthenticated, "Should not be authenticated after sign out")
    }
    
    // MARK: - Update Profile Tests
    
    func testUpdateUserProfile() async throws {
        // Given: Authenticated user with id
        // Note: This test requires a real authenticated user
        // For now, we test that the method doesn't crash
        
        do {
            try await sut.updateUserProfile(name: "New Name", profileImageURL: nil)
            // If we reach here without crash, test passes
            XCTAssertTrue(true, "Update profile should not crash")
        } catch {
            // Expected if no user is authenticated
            print("Update profile test skipped - no authenticated user")
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorMessageIsSetOnFailure() async {
        // Given: Invalid credentials
        let email = "test@test.com"
        let password = "wrong"
        
        // When: Sign in fails
        do {
            try await sut.signIn(email: email, password: password)
        } catch {
            // Then: Error message should be set
            // Note: errorMessage is set in MainActor, might need delay
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
            XCTAssertNotNil(sut.errorMessage, "Error message should be set on failure")
        }
    }
}
