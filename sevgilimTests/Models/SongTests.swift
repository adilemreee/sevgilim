//
//  SongTests.swift
//  sevgilimTests

import XCTest
@testable import sevgilim

final class SongTests: XCTestCase {
    
    func testSongInitialization() {
        let song = Song(
            id: UUID().uuidString,
            relationshipId: UUID().uuidString,
            title: "Our Song",
            artist: "Favorite Artist",
            spotifyURL: "spotify:track:123",
            albumArt: "https://example.com/album.jpg",
            addedBy: UUID().uuidString,
            addedAt: Date()
        )
        
        XCTAssertEqual(song.title, "Our Song")
        XCTAssertEqual(song.artist, "Favorite Artist")
        XCTAssertNotNil(song.spotifyURL)
    }
    
    func testSongWithoutSpotify() {
        let song = Song(
            relationshipId: UUID().uuidString,
            title: "Manual Song",
            artist: "Artist",
            spotifyURL: nil,
            albumArt: nil,
            addedBy: UUID().uuidString,
            addedAt: Date()
        )
        
        XCTAssertNil(song.spotifyURL)
        XCTAssertNil(song.albumArt)
    }
}
