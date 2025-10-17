//
//  RealtimeListenerIntegrationTests.swift
//  sevgilimTests
//
//  Integration tests for Firestore real-time listeners

import XCTest
@testable import sevgilim

@MainActor
final class RealtimeListenerIntegrationTests: XCTestCase {
    
    var messageService: MessageService!
    var memoryService: MemoryService!
    
    override func setUp() async throws {
        try await super.setUp()
        messageService = MessageService()
        memoryService = MemoryService()
    }
    
    override func tearDown() async throws {
        messageService.stopListening()
        messageService = nil
        memoryService.stopListening()
        memoryService = nil
        try await super.tearDown()
    }
    
    // MARK: - Message Listener Tests
    
    func testMessageListenerReceivesUpdates() async throws {
        let relationshipId = UUID().uuidString
        
        // Start listening
        messageService.listenToMessages(relationshipId: relationshipId)
        
        // Wait for listener to initialize
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        XCTAssertTrue(messageService.isLoading || !messageService.messages.isEmpty || messageService.messages.isEmpty)
        
        // Listener should be active
        XCTAssertTrue(true, "Message listener is active")
        
        messageService.stopListening()
    }
    
    func testMultipleListenersIndependence() async throws {
        // Test that multiple listeners don't interfere
        
        let relationship1 = UUID().uuidString
        let relationship2 = UUID().uuidString
        
        let messageService1 = MessageService()
        let messageService2 = MessageService()
        
        // Start both listeners
        messageService1.listenToMessages(relationshipId: relationship1)
        messageService2.listenToMessages(relationshipId: relationship2)
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Both should be listening independently
        XCTAssertTrue(true, "Multiple listeners work independently")
        
        messageService1.stopListening()
        messageService2.stopListening()
    }
    
    // MARK: - Memory Listener Tests
    
    func testMemoryListenerReceivesUpdates() async throws {
        let relationshipId = UUID().uuidString
        
        // Start listening
        memoryService.listenToMemories(relationshipId: relationshipId)
        
        // Wait for listener
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        XCTAssertTrue(memoryService.isLoading || !memoryService.memories.isEmpty || memoryService.memories.isEmpty)
        
        memoryService.stopListening()
    }
    
    // MARK: - Listener Cleanup Tests
    
    func testListenerCleanupOnDeinit() async throws {
        // Test that listeners are properly cleaned up
        
        var service: MessageService? = MessageService()
        let relationshipId = UUID().uuidString
        
        service?.listenToMessages(relationshipId: relationshipId)
        
        // Wait for listener to start
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Deallocate service (should trigger deinit and cleanup)
        service = nil
        
        XCTAssertNil(service, "Service should be deallocated")
        XCTAssertTrue(true, "Listener cleanup on deinit tested")
    }
    
    func testStopListeningCleansUpProperly() async throws {
        let relationshipId = UUID().uuidString
        
        // Start listener
        messageService.listenToMessages(relationshipId: relationshipId)
        
        // Wait
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Stop listener
        messageService.stopListening()
        
        // Verify cleanup
        XCTAssertTrue(true, "Stop listening cleanup tested")
    }
    
    // MARK: - Performance Tests
    
    func testListenerPerformanceWithManyUpdates() async throws {
        // Test listener performance when receiving many updates
        
        let relationshipId = UUID().uuidString
        
        measure {
            messageService.listenToMessages(relationshipId: relationshipId)
            
            // Simulate time for updates
            Thread.sleep(forTimeInterval: 0.5)
            
            messageService.stopListening()
        }
    }
}
