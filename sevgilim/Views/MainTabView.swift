//
//  MainTabView.swift
//  sevgilim
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var relationshipService: RelationshipService
    @EnvironmentObject var surpriseService: SurpriseService
    @EnvironmentObject var memoryService: MemoryService
    @EnvironmentObject var photoService: PhotoService
    @EnvironmentObject var noteService: NoteService
    @EnvironmentObject var planService: PlanService
    @EnvironmentObject var movieService: MovieService
    @EnvironmentObject var placeService: PlaceService
    @EnvironmentObject var songService: SongService
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(0)
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Anasayfa")
                }
            
            MemoriesView()
                .tag(1)
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "heart.text.square.fill" : "heart.text.square")
                    Text("Anılar")
                }
            
            PhotosView()
                .tag(2)
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "photo.fill" : "photo")
                    Text("Fotoğraflar")
                }
            
            NotesView()
                .tag(3)
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "note.text" : "note.text")
                    Text("Notlar")
                }
            
            ProfileView()
                .tag(4)
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "person.fill" : "person")
                    Text("Profil")
                }
        }
        .accentColor(themeManager.currentTheme.primaryColor)
        .onAppear {
            // Tüm servislerin listener'larını başlat
            if let currentUser = authService.currentUser,
               let userId = currentUser.id,
               let relationshipId = currentUser.relationshipId {
                
                // Sürpriz servisini başlat
                surpriseService.listenToSurprises(relationshipId: relationshipId, userId: userId)
                
                // Diğer servisleri de başlat
                memoryService.listenToMemories(relationshipId: relationshipId)
                photoService.listenToPhotos(relationshipId: relationshipId)
                noteService.listenToNotes(relationshipId: relationshipId)
                planService.listenToPlans(relationshipId: relationshipId)
                movieService.listenToMovies(relationshipId: relationshipId)
                placeService.listenToPlaces(relationshipId: relationshipId)
                songService.listenToSongs(relationshipId: relationshipId)
            }
        }
    }
}


