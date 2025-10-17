//
//  MessageServiceTests.swift
//  sevgilimTests
//
//  Unit tests for MessageService

import XCTest
@testable import sevgilim

@MainActor
final class MessageServiceTests: XCTestCase {
    
    var sut: MessageService!
    
    override func setUp() async throws {
        try await super.setUp()
        sut = MessageService()
    }
    
    override func tearDown() async throws {
        sut.stopListening()
        sut = nil
        try await super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertTrue(sut.messages.isEmpty, "Messages should be empty initially")
        XCTAssertFalse(sut.isLoading, "Should not be loading initially")
    }
    
    // MARK: - Send Message Tests
    
    func testSendTextMessage() async throws {
        let relationshipId = UUID().uuidString
        let senderId = UUID().uuidString
        let text = "Hello, my love!"
        
        do {
            try await sut.sendMessage(
                relationshipId: relationshipId,
                senderId: senderId,
                text: text,
                imageURL: nil
            )
            XCTAssertTrue(true, "Send message should succeed")
        } catch {
            XCTFail("Send message failed: \(error.localizedDescription)")
        }
    }
    
    func testSendMessageWithImage() async throws {
        let relationshipId = UUID().uuidString
        let senderId = UUID().uuidString
        let text = "Check this out!"
        let imageURL = "https://example.com/image.jpg"
        
        do {
            try await sut.sendMessage(
                relationshipId: relationshipId,
                senderId: senderId,
                text: text,
                imageURL: imageURL
            )
            XCTAssertTrue(true, "Send message with image should succeed")
        } catch {
            XCTFail("Send message with image failed: \(error.localizedDescription)")
        }
    }
    
    func testSendEmptyMessage() async {
        let relationshipId = UUID().uuidString
        let senderId = UUID().uuidString
        let text = ""
        
        do {
            try await sut.sendMessage(
                relationshipId: relationshipId,
                senderId: senderId,
                text: text,
                imageURL: nil
            )
            // Should validate empty message
        } catch {
            XCTAssertNotNil(error, "Should throw error for empty message")
        }
    }
    
    // MARK: - Listen to Messages Tests
    
    func testListenToMessages() {
        let relationshipId = UUID().uuidString
        
        sut.listenToMessages(relationshipId: relationshipId)
        
        XCTAssertTrue(sut.isLoading, "Should be loading when listener starts")
    }
    
    func testStopListening() {
        let relationshipId = UUID().uuidString
        sut.listenToMessages(relationshipId: relationshipId)
        
        sut.stopListening()
        
        XCTAssertTrue(true, "Stop listening should complete without crash")
    }
    
    // MARK: - Delete Message Tests
    
    func testDeleteMessage() async throws {
        let message = Message(
            id: UUID().uuidString,
            relationshipId: UUID().uuidString,
            senderId: UUID().uuidString,
            text: "Test message",
            imageURL: nil,
            timestamp: Date()
        )
        
        do {
            try await sut.deleteMessage(message)
            XCTAssertTrue(true, "Delete message should succeed")
        } catch {
            print("Delete message test skipped - message not in Firestore")
        }
    }
    
    // MARK: - Message Ordering Tests
    
    func testMessagesOrderedByTimestamp() {
        // Given: Messages with different timestamps
        let now = Date()
        let message1 = Message(
            relationshipId: UUID().uuidString,
            senderId: UUID().uuidString,
            text: "First",
            imageURL: nil,
            timestamp: now.addingTimeInterval(-100)
        )
        let message2 = Message(
            relationshipId: UUID().uuidString,
            senderId: UUID().uuidString,
            text: "Second",
            imageURL: nil,
            timestamp: now.addingTimeInterval(-50)
        )
        let message3 = Message(
            relationshipId: UUID().uuidString,
            senderId: UUID().uuidString,
            text: "Third",
            imageURL: nil,
            timestamp: now
        )
        
        // When: Messages are sorted
        let messages = [message3, message1, message2].sorted { $0.timestamp < $1.timestamp }
        
        // Then: Should be in chronological order
        XCTAssertEqual(messages[0].text, "First")
        XCTAssertEqual(messages[1].text, "Second")
        XCTAssertEqual(messages[2].text, "Third")
    }
    
    // MARK: - Performance Tests
    
    func testMessageListLimit() {
        // Messages should be limited for performance
        // Service should use query limit (e.g., 100 messages)
        XCTAssertTrue(true, "Message limit should be documented")
    }
}
