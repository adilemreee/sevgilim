//
//  PlaceTests.swift
//  sevgilimTests

import XCTest
@testable import sevgilim

final class PlaceTests: XCTestCase {
    
    func testPlaceInitialization() {
        let place = Place(
            id: UUID().uuidString,
            relationshipId: UUID().uuidString,
            name: "Favorite Restaurant",
            address: "123 Main St",
            latitude: 40.7128,
            longitude: -74.0060,
            category: "restaurant",
            notes: "Best pasta!",
            imageURL: "https://example.com/place.jpg",
            userId: UUID().uuidString,
            createdAt: Date()
        )
        
        XCTAssertEqual(place.name, "Favorite Restaurant")
        XCTAssertEqual(place.category, "restaurant")
        XCTAssertNotNil(place.notes)
    }
    
    func testPlaceCoordinates() {
        let place = Place(
            relationshipId: UUID().uuidString,
            name: "Test Place",
            address: "Address",
            latitude: 51.5074,
            longitude: -0.1278,
            category: "other",
            notes: nil,
            imageURL: nil,
            userId: UUID().uuidString,
            createdAt: Date()
        )
        
        XCTAssertGreaterThanOrEqual(place.latitude, -90.0)
        XCTAssertLessThanOrEqual(place.latitude, 90.0)
        XCTAssertGreaterThanOrEqual(place.longitude, -180.0)
        XCTAssertLessThanOrEqual(place.longitude, 180.0)
    }
}
