//
//  NoteTests.swift
//  sevgilimTests

import XCTest
@testable import sevgilim

final class NoteTests: XCTestCase {
    
    func testNoteInitialization() {
        let now = Date()
        let note = Note(
            id: UUID().uuidString,
            relationshipId: UUID().uuidString,
            title: "My Note",
            content: "Sweet note for you",
            createdBy: UUID().uuidString,
            createdAt: now,
            updatedAt: now
        )
        
        XCTAssertEqual(note.title, "My Note")
        XCTAssertEqual(note.content, "Sweet note for you")
        XCTAssertFalse(note.content.isEmpty)
    }
    
    func testNoteTimestamp() {
        let now = Date()
        let note = Note(
            relationshipId: UUID().uuidString,
            title: "Test Note",
            content: "Test note",
            createdBy: UUID().uuidString,
            createdAt: now,
            updatedAt: now
        )
        
        XCTAssertEqual(note.createdAt, now)
        XCTAssertEqual(note.updatedAt, now)
    }
}
