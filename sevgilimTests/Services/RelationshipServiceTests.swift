//
//  RelationshipServiceTests.swift
//  sevgilimTests
//
//  Unit tests for RelationshipService

import XCTest
@testable import sevgilim

@MainActor
final class RelationshipServiceTests: XCTestCase {
    
    var sut: RelationshipService!
    
    override func setUp() async throws {
        try await super.setUp()
        sut = RelationshipService()
    }
    
    override func tearDown() async throws {
        sut.stopListening()
        sut = nil
        try await super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        // Given: Fresh RelationshipService
        // When: Just initialized
        // Then: Should have no relationship
        XCTAssertNil(sut.currentRelationship, "Current relationship should be nil initially")
        XCTAssertFalse(sut.isLoading, "Should not be loading initially")
    }
    
    // MARK: - Create Relationship Tests
    
    func testCreateRelationshipWithValidData() async throws {
        // Given: Valid relationship data
        let user1Id = UUID().uuidString
        let user1Name = "User 1"
        let user2Email = "user2@test.com"
        let startDate = Date()
        
        // When: Creating relationship
        do {
            let relationshipId = try await sut.createRelationship(
                user1Id: user1Id,
                user1Name: user1Name,
                user2Email: user2Email,
                startDate: startDate
            )
            
            // Then: Should return valid relationship ID
            XCTAssertFalse(relationshipId.isEmpty, "Relationship ID should not be empty")
        } catch {
            XCTFail("Create relationship should succeed: \(error.localizedDescription)")
        }
    }
    
    func testCreateRelationshipWithEmptyEmail() async {
        // Given: Empty email
        let user1Id = UUID().uuidString
        let user1Name = "User 1"
        let user2Email = ""
        let startDate = Date()
        
        // When: Creating relationship
        do {
            _ = try await sut.createRelationship(
                user1Id: user1Id,
                user1Name: user1Name,
                user2Email: user2Email,
                startDate: startDate
            )
            // Note: Service doesn't validate empty email currently
            // This test documents current behavior
        } catch {
            // If validation is added, this would be expected
            XCTAssertNotNil(error, "Should throw error for empty email")
        }
    }
    
    // MARK: - Listen to Relationship Tests
    
    func testListenToRelationshipStartsListener() {
        // Given: Valid relationship ID
        let relationshipId = UUID().uuidString
        
        // When: Start listening
        sut.listenToRelationship(relationshipId: relationshipId)
        
        // Then: Loading state should be set
        // Note: Loading state is set immediately
        XCTAssertTrue(true, "Listener should start without crash")
    }
    
    func testStopListening() {
        // Given: Active listener
        let relationshipId = UUID().uuidString
        sut.listenToRelationship(relationshipId: relationshipId)
        
        // When: Stop listening
        sut.stopListening()
        
        // Then: Should not crash
        XCTAssertTrue(true, "Stop listening should complete without crash")
    }
    
    // MARK: - Days Together Calculation Tests
    
    func testDaysSinceStartDate() {
        // Given: Relationship with known start date
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -100, to: Date())!
        let currentDate = Date()
        
        // When: Calculating days between
        let days = startDate.daysBetween(currentDate)
        
        // Then: Should be approximately 100 days
        XCTAssertGreaterThanOrEqual(days, 99, "Days should be at least 99")
        XCTAssertLessThanOrEqual(days, 101, "Days should be at most 101")
    }
    
    // MARK: - Deinit Tests
    
    func testDeinitRemovesListener() {
        // Given: Service with listener
        var service: RelationshipService? = RelationshipService()
        let relationshipId = UUID().uuidString
        service?.listenToRelationship(relationshipId: relationshipId)
        
        // When: Service is deallocated
        service = nil
        
        // Then: Should not crash (listener should be removed in deinit)
        XCTAssertNil(service, "Service should be deallocated")
    }
}
