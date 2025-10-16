//
//  MainTabView.swift
//  sevgilim
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var themeManager: ThemeManager
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
    }
}


