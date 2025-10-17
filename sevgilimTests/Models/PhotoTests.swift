//
//  PhotoTests.swift
//  sevgilimTests
//
//  Unit tests for Photo model

import XCTest
@testable import sevgilim

final class PhotoTests: XCTestCase {
    
    func testPhotoInitialization() {
        let photoDate = Date()
        let photo = Photo(
            id: UUID().uuidString,
            relationshipId: UUID().uuidString,
            imageURL: "https://example.com/photo.jpg",
            thumbnailURL: "https://example.com/thumb.jpg",
            title: "Beautiful moment",
            date: photoDate,
            location: "Paris",
            tags: ["vacation", "romantic"],
            uploadedBy: UUID().uuidString,
            createdAt: Date()
        )
        
        XCTAssertNotNil(photo.id)
        XCTAssertFalse(photo.imageURL.isEmpty)
        XCTAssertEqual(photo.title, "Beautiful moment")
        XCTAssertEqual(photo.date, photoDate)
        XCTAssertEqual(photo.tags?.count, 2)
    }
    
    func testPhotoWithoutTitle() {
        let photo = Photo(
            relationshipId: UUID().uuidString,
            imageURL: "https://example.com/photo.jpg",
            thumbnailURL: nil,
            title: nil,
            date: Date(),
            location: nil,
            tags: nil,
            uploadedBy: UUID().uuidString,
            createdAt: Date()
        )
        
        XCTAssertNil(photo.title)
        XCTAssertNil(photo.location)
        XCTAssertNil(photo.tags)
    }
    
    func testPhotoTags() {
        let photo = Photo(
            relationshipId: UUID().uuidString,
            imageURL: "test.jpg",
            thumbnailURL: nil,
            title: nil,
            date: Date(),
            location: nil,
            tags: ["beach", "sunset"],
            uploadedBy: UUID().uuidString,
            createdAt: Date()
        )
        
        XCTAssertEqual(photo.tags?.count, 2)
        XCTAssertTrue(photo.tags?.contains("beach") ?? false)
    }
}
