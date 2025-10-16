//
//  AddSongView.swift
//  sevgilim
//

import SwiftUI

struct AddSongView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var songService: SongService
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var spotifyService = SpotifyService()
    
    @State private var title = ""
    @State private var artist = ""
    @State private var imageUrl = ""
    @State private var spotifyLink = ""
    @State private var appleMusicLink = ""
    @State private var youtubeLink = ""
    @State private var note = ""
    @State private var date = Date()
    @State private var isAdding = false
    @State private var searchText = ""
    @State private var selectedTrack: SpotifyTrack?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Spotify'dan Şarkı Ara") {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Şarkı ara...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .onChange(of: searchText) { _, newValue in
                                if !newValue.isEmpty {
                                    Task {
                                        await spotifyService.searchTracks(query: newValue)
                                    }
                                } else {
                                    spotifyService.clearSearch()
                                }
                            }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    if spotifyService.isSearching {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Aranıyor...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if !spotifyService.searchResults.isEmpty {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(spotifyService.searchResults) { track in
                                    SpotifyTrackRow(track: track) {
                                        selectTrack(track)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                }
                
                Section("Seçilen Şarkı") {
                    if let track = selectedTrack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                AsyncImage(url: URL(string: track.album.images.first?.url ?? "")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                }
                                .frame(width: 50, height: 50)
                                .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(track.name)
                                        .font(.headline)
                                        .lineLimit(1)
                                    
                                    Text(track.artistNames)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Button("Seç") {
                                    selectTrack(track)
                                }
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(themeManager.currentTheme.primaryColor)
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(themeManager.currentTheme.primaryColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                    } else {
                        Text("Spotify'dan şarkı seçin")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                }
                
                Section("Şarkı Bilgileri") {
                    TextField("Şarkı Adı", text: $title)
                    TextField("Sanatçı", text: $artist)
                    DatePicker("Dinleme Tarihi", selection: $date, displayedComponents: .date)
                }
                
                Section("Müzik Platform Linkleri") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Spotify Link")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        HStack {
                            Image(systemName: "music.note")
                                .foregroundColor(.green)
                            TextField("https://open.spotify.com/track/...", text: $spotifyLink)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                
                    
                
                }
                
                Section("Not") {
                    TextField("Bu şarkı hakkında not ekleyin...", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
                
             
            }
            .navigationTitle("Şarkı Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        addSong()
                    }
                    .disabled(title.isEmpty || artist.isEmpty || isAdding)
                }
            }
            .overlay {
                if isAdding {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 15) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Ekleniyor...")
                                .foregroundColor(.white)
                        }
                        .padding(30)
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                    }
                }
            }
        }
    }
    
    private func selectTrack(_ track: SpotifyTrack) {
        selectedTrack = track
        title = track.name
        artist = track.artistNames
        imageUrl = track.album.images.first?.url ?? ""
        spotifyLink = track.spotifyURL
        searchText = ""
        spotifyService.clearSearch()
    }
    
    private func addSong() {
        guard let userId = authService.currentUser?.id,
              let relationshipId = authService.currentUser?.relationshipId else { return }
        
        isAdding = true
        Task {
            do {
                try await songService.addSong(
                    relationshipId: relationshipId,
                    title: title,
                    artist: artist,
                    imageUrl: imageUrl.isEmpty ? nil : imageUrl,
                    spotifyLink: spotifyLink.isEmpty ? nil : spotifyLink,
                    appleMusicLink: appleMusicLink.isEmpty ? nil : appleMusicLink,
                    youtubeLink: youtubeLink.isEmpty ? nil : youtubeLink,
                    note: note.isEmpty ? nil : note,
                    date: date,
                    userId: userId
                )
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Error adding song: \(error)")
                await MainActor.run {
                    isAdding = false
                }
            }
        }
    }
}

// MARK: - Spotify Track Row
struct SpotifyTrackRow: View {
    let track: SpotifyTrack
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: track.album.images.first?.url ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 40, height: 40)
                .cornerRadius(6)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(track.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(track.artistNames)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "plus.circle")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
