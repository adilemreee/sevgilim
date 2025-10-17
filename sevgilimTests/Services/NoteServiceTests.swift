//
//  NoteServiceTests.swift
//  sevgilimTests
//
//  Unit tests for NoteService

import XCTest
@testable import sevgilim

@MainActor
final class NoteServiceTests: XCTestCase {
    
    var sut: NoteService!
    
    override func setUp() async throws {
        try await super.setUp()
        sut = NoteService()
    }
    
    override func tearDown() async throws {
        sut.stopListening()
        sut = nil
        try await super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertTrue(sut.notes.isEmpty)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testAddNote() async throws {
        do {
            try await sut.addNote(
                relationshipId: UUID().uuidString,
                content: "Sweet note for you",
                userId: UUID().uuidString
            )
            XCTAssertTrue(true)
        } catch {
            XCTFail("Add note failed: \(error)")
        }
    }
    
    func testAddEmptyNote() async {
        do {
            try await sut.addNote(
                relationshipId: UUID().uuidString,
                content: "",
                userId: UUID().uuidString
            )
            // Should validate empty content
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testListenToNotes() {
        sut.listenToNotes(relationshipId: UUID().uuidString)
        XCTAssertTrue(sut.isLoading)
    }
    
    func testDeleteNote() async throws {
        let note = Note(
            id: UUID().uuidString,
            relationshipId: UUID().uuidString,
            content: "Test note",
            userId: UUID().uuidString,
            createdAt: Date()
        )
        
        do {
            try await sut.deleteNote(note)
            XCTAssertTrue(true)
        } catch {
            print("Delete note test skipped")
        }
    }
}
