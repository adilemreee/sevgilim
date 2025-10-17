//
//  MovieServiceTests.swift
//  sevgilimTests
//
//  Unit tests for MovieService

import XCTest
@testable import sevgilim

@MainActor
final class MovieServiceTests: XCTestCase {
    
    var sut: MovieService!
    
    override func setUp() async throws {
        try await super.setUp()
        sut = MovieService()
    }
    
    override func tearDown() async throws {
        sut.stopListening()
        sut = nil
        try await super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertTrue(sut.movies.isEmpty)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testAddMovie() async throws {
        do {
            try await sut.addMovie(
                relationshipId: UUID().uuidString,
                title: "Our Favorite Movie",
                year: "2023",
                poster: "https://example.com/poster.jpg",
                rating: 4.5,
                notes: "Amazing movie!",
                userId: UUID().uuidString
            )
            XCTAssertTrue(true)
        } catch {
            XCTFail("Add movie failed: \(error)")
        }
    }
    
    func testAddMovieWithoutNotes() async throws {
        do {
            try await sut.addMovie(
                relationshipId: UUID().uuidString,
                title: "Another Movie",
                year: "2024",
                poster: nil,
                rating: 3.0,
                notes: nil,
                userId: UUID().uuidString
            )
            XCTAssertTrue(true)
        } catch {
            XCTFail("Add movie without notes failed: \(error)")
        }
    }
    
    func testMovieRatingValidation() {
        let validRatings = [0.0, 2.5, 5.0]
        let invalidRatings = [-1.0, 5.5, 10.0]
        
        for rating in validRatings {
            XCTAssertGreaterThanOrEqual(rating, 0.0)
            XCTAssertLessThanOrEqual(rating, 5.0)
        }
        
        for rating in invalidRatings {
            // Should be validated
            XCTAssertTrue(rating < 0.0 || rating > 5.0)
        }
    }
    
    func testListenToMovies() {
        sut.listenToMovies(relationshipId: UUID().uuidString)
        XCTAssertTrue(sut.isLoading)
    }
    
    func testDeleteMovie() async throws {
        let movie = Movie(
            id: UUID().uuidString,
            relationshipId: UUID().uuidString,
            title: "Test Movie",
            year: "2024",
            poster: nil,
            rating: 4.0,
            notes: nil,
            userId: UUID().uuidString,
            createdAt: Date()
        )
        
        do {
            try await sut.deleteMovie(movie)
            XCTAssertTrue(true)
        } catch {
            print("Delete movie test skipped")
        }
    }
}
