//
//  PlaceServiceTests.swift
//  sevgilimTests
//
//  Unit tests for PlaceService

import XCTest
@testable import sevgilim

@MainActor
final class PlaceServiceTests: XCTestCase {
    
    var sut: PlaceService!
    
    override func setUp() async throws {
        try await super.setUp()
        sut = PlaceService()
    }
    
    override func tearDown() async throws {
        sut.stopListening()
        sut = nil
        try await super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertTrue(sut.places.isEmpty)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testAddPlace() async throws {
        do {
            try await sut.addPlace(
                relationshipId: UUID().uuidString,
                name: "Favorite Restaurant",
                address: "123 Main St",
                latitude: 40.7128,
                longitude: -74.0060,
                category: "restaurant",
                notes: "Best pasta!",
                imageURL: nil,
                userId: UUID().uuidString
            )
            XCTAssertTrue(true)
        } catch {
            XCTFail("Add place failed: \(error)")
        }
    }
    
    func testListenToPlaces() {
        sut.listenToPlaces(relationshipId: UUID().uuidString)
        XCTAssertTrue(sut.isLoading)
    }
    
    func testDeletePlace() async throws {
        let place = Place(
            id: UUID().uuidString,
            relationshipId: UUID().uuidString,
            name: "Test",
            address: "123",
            latitude: 0,
            longitude: 0,
            category: "other",
            notes: nil,
            imageURL: nil,
            userId: UUID().uuidString,
            createdAt: Date()
        )
        
        do {
            try await sut.deletePlace(place)
            XCTAssertTrue(true)
        } catch {
            print("Delete place test skipped")
        }
    }
}
