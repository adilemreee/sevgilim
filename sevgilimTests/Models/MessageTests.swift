//
//  MessageTests.swift
//  sevgilimTests
//
//  Unit tests for Message model

import XCTest
@testable import sevgilim

final class MessageTests: XCTestCase {
    
    func testMessageInitialization() {
        let id = UUID().uuidString
        let relationshipId = UUID().uuidString
        let senderId = UUID().uuidString
        let senderName = "Test User"
        let text = "Hello!"
        let imageURL = "https://example.com/image.jpg"
        let timestamp = Date()
        
        let message = Message(
            id: id,
            relationshipId: relationshipId,
            senderId: senderId,
            senderName: senderName,
            text: text,
            imageURL: imageURL,
            timestamp: timestamp,
            isRead: false
        )
        
        XCTAssertEqual(message.id, id)
        XCTAssertEqual(message.relationshipId, relationshipId)
        XCTAssertEqual(message.senderId, senderId)
        XCTAssertEqual(message.senderName, senderName)
        XCTAssertEqual(message.text, text)
        XCTAssertEqual(message.imageURL, imageURL)
        XCTAssertEqual(message.timestamp, timestamp)
        XCTAssertFalse(message.isRead)
    }
    
    func testMessageWithoutImage() {
        let message = Message(
            relationshipId: UUID().uuidString,
            senderId: UUID().uuidString,
            senderName: "Test User",
            text: "Text only",
            imageURL: nil,
            timestamp: Date(),
            isRead: false
        )
        
        XCTAssertNil(message.imageURL)
        XCTAssertFalse(message.text.isEmpty)
    }
    
    func testMessageTimestampOrdering() {
        let now = Date()
        let message1 = Message(
            relationshipId: UUID().uuidString,
            senderId: UUID().uuidString,
            senderName: "User 1",
            text: "First",
            imageURL: nil,
            timestamp: now.addingTimeInterval(-100),
            isRead: false
        )
        let message2 = Message(
            relationshipId: UUID().uuidString,
            senderId: UUID().uuidString,
            senderName: "User 2",
            text: "Second",
            imageURL: nil,
            timestamp: now,
            isRead: false
        )
        
        XCTAssertLessThan(message1.timestamp, message2.timestamp)
    }
}
