//
//  StoryCircles.swift
//  sevgilim
//

import SwiftUI

enum StorySource {
    case user
    case partner
}

struct StoryCircles: View {
    @EnvironmentObject var storyService: StoryService
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var showingStoryViewer = false
    @State private var showingAddStory = false
    @State private var selectedSource: StorySource = .user
    @State private var startIndex: Int = 0
    
    // İlk izlenmemiş story'nin index'ini bul
    private func getStartIndex(for stories: [Story], userId: String) -> Int {
        // İlk izlenmemiş story'yi bul
        if let firstUnviewed = stories.firstIndex(where: { !$0.isViewedBy(userId: userId) }) {
            return firstUnviewed
        }
        // Hepsi izlenmişse baştan başla
        return 0
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                // User's Story Circle
                if let currentUser = authService.currentUser {
                    VStack(spacing: 8) {
                        ZStack {
                            // Circle with gradient border
                            if !storyService.userStories.isEmpty {
                                // Has stories - show with gradient border
                                let allViewed = storyService.userStories.allSatisfy { $0.isViewedBy(userId: currentUser.id ?? "") }
                                
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: allViewed ?
                                                [.gray.opacity(0.5), .gray.opacity(0.3)] :
                                                [themeManager.currentTheme.primaryColor, themeManager.currentTheme.secondaryColor],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 74, height: 74)
                                
                                // Avatar
                                UserAvatarView(photoURL: currentUser.profileImageURL)
                                
                                // Story count badge
                                if storyService.userStories.count > 1 {
                                    Text("\(storyService.userStories.count)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 22, height: 22)
                                        .background(themeManager.currentTheme.primaryColor)
                                        .clipShape(Circle())
                                        .overlay {
                                            Circle()
                                                .stroke(.white, lineWidth: 2)
                                        }
                                        .offset(x: 25, y: -25)
                                }
                            } else {
                                // No story - show add button
                                Circle()
                                    .fill(.gray.opacity(0.2))
                                    .frame(width: 74, height: 74)
                                
                                UserAvatarView(photoURL: currentUser.profileImageURL)
                                
                                // Plus button
                                Circle()
                                    .fill(themeManager.currentTheme.primaryColor)
                                    .frame(width: 24, height: 24)
                                    .overlay {
                                        Image(systemName: "plus")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    .offset(x: 25, y: 25)
                            }
                        }
                        .onTapGesture {
                            if !storyService.userStories.isEmpty, let userId = authService.currentUser?.id {
                                selectedSource = .user
                                startIndex = getStartIndex(for: storyService.userStories, userId: userId)
                                showingStoryViewer = true
                            } else {
                                showingAddStory = true
                            }
                        }
                        
                        Text("Hikayem")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    .frame(width: 74)
                }
                
                // Partner's Story Circle
                if !storyService.partnerStories.isEmpty,
                   let currentUserId = authService.currentUser?.id,
                   let firstPartnerStory = storyService.partnerStories.first {
                    VStack(spacing: 8) {
                        ZStack {
                            // Circle with gradient border
                            let allViewed = storyService.partnerStories.allSatisfy { $0.isViewedBy(userId: currentUserId) }
                            
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: allViewed ?
                                            [.gray.opacity(0.5), .gray.opacity(0.3)] :
                                            [.pink, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 74, height: 74)
                            
                            // Avatar
                            UserAvatarView(photoURL: firstPartnerStory.createdByPhotoURL)
                            
                            // Story count badge
                            if storyService.partnerStories.count > 1 {
                                Text("\(storyService.partnerStories.count)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 22, height: 22)
                                    .background(Color.pink)
                                    .clipShape(Circle())
                                    .overlay {
                                        Circle()
                                            .stroke(.white, lineWidth: 2)
                                    }
                                    .offset(x: 25, y: -25)
                            }
                        }
                        .onTapGesture {
                            if let userId = authService.currentUser?.id {
                                selectedSource = .partner
                                startIndex = getStartIndex(for: storyService.partnerStories, userId: userId)
                                showingStoryViewer = true
                            }
                        }
                        
                        Text(firstPartnerStory.createdByName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    .frame(width: 74)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .fullScreenCover(isPresented: $showingStoryViewer) {
            let stories = selectedSource == .user ? storyService.userStories : storyService.partnerStories
            if !stories.isEmpty {
                StoryViewer(stories: stories, startIndex: startIndex)
                    .environmentObject(storyService)
                    .environmentObject(authService)
                    .environmentObject(themeManager)
            }
        }
        .sheet(isPresented: $showingAddStory) {
            AddStoryView()
                .environmentObject(storyService)
                .environmentObject(authService)
                .environmentObject(themeManager)
        }
    }
}

// MARK: - User Avatar View
struct UserAvatarView: View {
    let photoURL: String?
    
    var body: some View {
        if let photoURL = photoURL {
            AsyncImage(url: URL(string: photoURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Circle()
                    .fill(.gray.opacity(0.3))
                    .overlay {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                    }
            }
            .frame(width: 68, height: 68)
            .clipShape(Circle())
        } else {
            Circle()
                .fill(.gray.opacity(0.3))
                .frame(width: 68, height: 68)
                .overlay {
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 30))
                }
        }
    }
}
