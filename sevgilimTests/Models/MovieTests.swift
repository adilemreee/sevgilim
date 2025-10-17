//
//  MovieTests.swift
//  sevgilimTests

import XCTest
@testable import sevgilim

final class MovieTests: XCTestCase {
    
    func testMovieInitialization() {
        let watchedDate = Date()
        let movie = Movie(
            id: UUID().uuidString,
            relationshipId: UUID().uuidString,
            title: "Favorite Movie",
            watchedDate: watchedDate,
            rating: 4,
            notes: "Amazing!",
            posterURL: "https://example.com/poster.jpg",
            addedBy: UUID().uuidString,
            createdAt: Date()
        )
        
        XCTAssertEqual(movie.title, "Favorite Movie")
        XCTAssertEqual(movie.rating, 4)
        XCTAssertNotNil(movie.notes)
        XCTAssertEqual(movie.watchedDate, watchedDate)
    }
    
    func testMovieRating() {
        let movie = Movie(
            relationshipId: UUID().uuidString,
            title: "Test Movie",
            watchedDate: Date(),
            rating: 3,
            notes: nil,
            posterURL: nil,
            addedBy: UUID().uuidString,
            createdAt: Date()
        )
        
        XCTAssertGreaterThanOrEqual(movie.rating ?? 0, 0)
        XCTAssertLessThanOrEqual(movie.rating ?? 5, 5)
    }
}
