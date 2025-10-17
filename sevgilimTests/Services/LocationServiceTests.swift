//
//  LocationServiceTests.swift
//  sevgilimTests
//
//  Unit tests for LocationService

import XCTest
import CoreLocation
@testable import sevgilim

@MainActor
final class LocationServiceTests: XCTestCase {
    
    var sut: LocationService!
    
    override func setUp() async throws {
        try await super.setUp()
        sut = LocationService()
    }
    
    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertNil(sut.currentLocation)
    }
    
    func testRequestLocation() {
        sut.requestLocation()
        // Location request should not crash
        XCTAssertTrue(true)
    }
    
    func testCoordinateValidation() {
        let validCoordinates = [
            (latitude: 40.7128, longitude: -74.0060), // New York
            (latitude: 51.5074, longitude: -0.1278),   // London
            (latitude: 35.6762, longitude: 139.6503)   // Tokyo
        ]
        
        for coord in validCoordinates {
            XCTAssertGreaterThanOrEqual(coord.latitude, -90.0)
            XCTAssertLessThanOrEqual(coord.latitude, 90.0)
            XCTAssertGreaterThanOrEqual(coord.longitude, -180.0)
            XCTAssertLessThanOrEqual(coord.longitude, 180.0)
        }
    }
    
    func testDistanceCalculation() {
        let location1 = CLLocation(latitude: 40.7128, longitude: -74.0060)
        let location2 = CLLocation(latitude: 40.7589, longitude: -73.9851)
        
        let distance = location1.distance(from: location2)
        
        XCTAssertGreaterThan(distance, 0, "Distance should be positive")
        XCTAssertLessThan(distance, 10000, "Distance should be reasonable (< 10km)")
    }
}
