//
//  SpotifyService.swift
//  sevgilim
//

import Foundation
import Combine

@MainActor
class SpotifyService: ObservableObject {
    @Published var searchResults: [SpotifyTrack] = []
    @Published var isSearching = false
    @Published var searchQuery = ""
    
    private let clientId = "ebb22c9c8dd9465b95c93902edb083c6" // Bu değeri Spotify Developer Dashboard'dan alın
    private let clientSecret = "0d3b4d9106c44439936fc08a470ace81" // Bu değeri Spotify Developer Dashboard'dan alın
    private var accessToken: String?
    
    func searchTracks(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        searchQuery = query
        
        do {
            // Önce access token al
            if accessToken == nil {
                try await getAccessToken()
            }
            
            guard let token = accessToken else {
                print("❌ No access token available")
                isSearching = false
                return
            }
            
            // Spotify API'den şarkı ara
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let urlString = "https://api.spotify.com/v1/search?q=\(encodedQuery)&type=track&limit=20"
            
            guard let url = URL(string: urlString) else {
                print("❌ Invalid URL")
                isSearching = false
                return
            }
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ HTTP Error: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                isSearching = false
                return
            }
            
            let searchResponse = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
            searchResults = searchResponse.tracks.items
            
        } catch {
            print("❌ Error searching tracks: \(error.localizedDescription)")
            searchResults = []
        }
        
        isSearching = false
    }
    
    private func getAccessToken() async throws {
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let credentials = "\(clientId):\(clientSecret)"
        let encodedCredentials = Data(credentials.utf8).base64EncodedString()
        request.setValue("Basic \(encodedCredentials)", forHTTPHeaderField: "Authorization")
        
        let body = "grant_type=client_credentials"
        request.httpBody = body.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SpotifyError.invalidCredentials
        }
        
        let tokenResponse = try JSONDecoder().decode(SpotifyTokenResponse.self, from: data)
        accessToken = tokenResponse.access_token
    }
    
    func clearSearch() {
        searchResults = []
        searchQuery = ""
    }
}

// MARK: - Spotify Models
struct SpotifyTrack: Identifiable, Codable {
    let id: String
    let name: String
    let artists: [SpotifyArtist]
    let album: SpotifyAlbum
    let external_urls: SpotifyExternalUrls
    let preview_url: String?
    let duration_ms: Int
    
    var artistNames: String {
        artists.map { $0.name }.joined(separator: ", ")
    }
    
    var spotifyURL: String {
        external_urls.spotify
    }
}

struct SpotifyArtist: Codable {
    let id: String
    let name: String
}

struct SpotifyAlbum: Codable {
    let id: String
    let name: String
    let images: [SpotifyImage]
}

struct SpotifyImage: Codable {
    let url: String
    let height: Int?
    let width: Int?
}

struct SpotifyExternalUrls: Codable {
    let spotify: String
}

struct SpotifySearchResponse: Codable {
    let tracks: SpotifyTracksResponse
}

struct SpotifyTracksResponse: Codable {
    let items: [SpotifyTrack]
}

struct SpotifyTokenResponse: Codable {
    let access_token: String
    let token_type: String
    let expires_in: Int
}

enum SpotifyError: Error {
    case invalidCredentials
    case networkError
    case invalidResponse
}
