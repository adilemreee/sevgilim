//
//  StoryCircles.swift
//  sevgilim
//

import SwiftUI

struct StoryCircles: View {
    @EnvironmentObject var storyService: StoryService
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var showingStoryViewer = false
    @State private var showingAddStory = false
    @State private var selectedStoryIndex = 0
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                // User's Story Circle (Add Story)
                if let currentUser = authService.currentUser {
                    VStack(spacing: 8) {
                        ZStack {
                            // Circle with gradient border
                            if let userStory = storyService.userStory {
                                // Has story - show with gradient border
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: userStory.isViewedBy(userId: currentUser.id ?? "") ?
                                                [.gray.opacity(0.5), .gray.opacity(0.3)] :
                                                [themeManager.currentTheme.primaryColor, themeManager.currentTheme.secondaryColor],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 74, height: 74)
                                
                                // Avatar
                                if let photoURL = currentUser.profileImageURL {
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
                            } else {
                                // No story - show add button
                                Circle()
                                    .fill(.gray.opacity(0.2))
                                    .frame(width: 68, height: 68)
                                
                                if let photoURL = currentUser.profileImageURL {
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
                            if storyService.userStory != nil {
                                // Show user's story
                                selectedStoryIndex = 0
                                showingStoryViewer = true
                            } else {
                                // Add new story
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
                if let partnerStory = storyService.partnerStory,
                   let currentUserId = authService.currentUser?.id {
                    VStack(spacing: 8) {
                        ZStack {
                            // Circle with gradient border
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: partnerStory.isViewedBy(userId: currentUserId) ?
                                            [.gray.opacity(0.5), .gray.opacity(0.3)] :
                                            [.pink, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 74, height: 74)
                            
                            // Avatar
                            if let photoURL = partnerStory.createdByPhotoURL {
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
                                    .fill(LinearGradient(
                                        colors: [.pink, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 68, height: 68)
                                    .overlay {
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 30))
                                    }
                            }
                        }
                        .onTapGesture {
                            // Show partner's story
                            selectedStoryIndex = storyService.userStory != nil ? 1 : 0
                            showingStoryViewer = true
                        }
                        
                        Text(partnerStory.createdByName)
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
            if !allStories.isEmpty {
                StoryViewer(stories: allStories, startIndex: selectedStoryIndex)
            }
        }
        .sheet(isPresented: $showingAddStory) {
            AddStoryView()
        }
    }
    
    // All stories in order (user first, then partner)
    private var allStories: [Story] {
        var stories: [Story] = []
        if let userStory = storyService.userStory {
            stories.append(userStory)
        }
        if let partnerStory = storyService.partnerStory {
            stories.append(partnerStory)
        }
        return stories
    }
}
