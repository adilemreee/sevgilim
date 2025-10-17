//
//  StoryViewer.swift
//  sevgilim
//

import SwiftUI

struct StoryViewer: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var storyService: StoryService
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var themeManager: ThemeManager
    
    let stories: [Story] // Görüntülenecek story'ler (user + partner)
    let startIndex: Int
    
    @State private var currentIndex: Int
    @State private var progress: CGFloat = 0
    @State private var timer: Timer?
    @State private var isPaused = false
    @State private var cachedImage: UIImage?
    @State private var isLoading = true
    @State private var dragOffset: CGFloat = 0
    @State private var showingDeleteAlert = false
    @State private var showingAddStory = false
    
    private let storyDuration: TimeInterval = 5 // 5 saniye
    
    init(stories: [Story], startIndex: Int = 0) {
        self.stories = stories
        self.startIndex = startIndex
        _currentIndex = State(initialValue: startIndex)
    }
    
    var currentStory: Story? {
        guard currentIndex < stories.count else { return nil }
        return stories[currentIndex]
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if stories.isEmpty {
                // Hiç story yok
                VStack(spacing: 20) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("Story bulunamadı")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
            } else if let story = currentStory {
                // Story Content
                ZStack {
                    // Cached Image
                    if let image = cachedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if isLoading {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                    }
                    
                    // Gradient Overlay (üst ve alt)
                    VStack(spacing: 0) {
                        LinearGradient(
                            colors: [.black.opacity(0.6), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 150)
                        
                        Spacer()
                        
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 100)
                    }
                    .allowsHitTesting(false)
                    
                    // Top Content (Progress + Header)
                    VStack(spacing: 12) {
                        // Progress Bars
                        HStack(spacing: 4) {
                            ForEach(0..<stories.count, id: \.self) { index in
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        // Background
                                        Rectangle()
                                            .fill(.white.opacity(0.3))
                                        
                                        // Progress
                                        Rectangle()
                                            .fill(.white)
                                            .frame(width: progressWidth(for: index, geometry: geometry))
                                    }
                                }
                                .frame(height: 2)
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 50)
                        
                        // Header (Avatar + Name + Time)
                        HStack(spacing: 12) {
                            // Avatar - Cached
                            CachedAvatarView(photoURL: story.createdByPhotoURL, size: 36)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(story.createdByName)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text(story.timeAgoText)
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            // Add Story Button (only for own stories)
                            if story.createdBy == authService.currentUser?.id {
                                Button(action: { 
                                    showingAddStory = true
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 32)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                }
                            }
                            
                            // Delete Button (only for own stories)
                            if story.createdBy == authService.currentUser?.id {
                                Button(action: { 
                                    showingDeleteAlert = true
                                }) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 32)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                }
                            }
                            
                            // Close Button
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        Spacer()
                    }
                    .zIndex(1) // Butonlar en üstte
                    
                    // Tap Areas (Left = Previous, Right = Next) - Sadece orta alanda
                    VStack(spacing: 0) {
                        // Üst kısım boş (butonların alanı)
                        Color.clear
                            .frame(height: 150)
                            .allowsHitTesting(false)
                        
                        // Orta kısım - Tap Areas
                        HStack(spacing: 0) {
                            // Left Tap Area (Previous)
                            Rectangle()
                                .fill(.clear)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    previousStory()
                                }
                            
                            // Right Tap Area (Next)
                            Rectangle()
                                .fill(.clear)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    nextStory()
                                }
                        }
                        
                        // Alt kısım boş
                        Color.clear
                            .frame(height: 100)
                            .allowsHitTesting(false)
                    }
                }
                .offset(x: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.width
                            pauseTimer()
                        }
                        .onEnded { value in
                            if value.translation.width < -100 {
                                nextStory()
                            } else if value.translation.width > 100 {
                                previousStory()
                            }
                            dragOffset = 0
                            resumeTimer()
                        }
                )
            } else {
                // currentStory nil - bu olmamalı
                VStack(spacing: 20) {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                    
                    Text("Story yükleniyor...")
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            loadCurrentStory()
            startTimer()
            markAsViewed()
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: currentIndex) { _, _ in
            loadCurrentStory()
            progress = 0
            startTimer()
            markAsViewed()
        }
        .alert("Story'yi Sil", isPresented: $showingDeleteAlert) {
            Button("İptal", role: .cancel) { }
            Button("Sil", role: .destructive) {
                deleteCurrentStory()
            }
        } message: {
            Text("Bu story'yi silmek istediğinizden emin misiniz?")
        }
        .sheet(isPresented: $showingAddStory) {
            AddStoryView()
                .environmentObject(storyService)
                .environmentObject(authService)
                .environmentObject(themeManager)
        }
        .onChange(of: showingAddStory) { _, newValue in
            if newValue {
                pauseTimer()
            } else {
                resumeTimer()
            }
        }
        .onChange(of: showingDeleteAlert) { _, newValue in
            if newValue {
                pauseTimer()
            } else {
                resumeTimer()
            }
        }
        .statusBar(hidden: true)
    }
    
    // MARK: - Progress Width
    private func progressWidth(for index: Int, geometry: GeometryProxy) -> CGFloat {
        if index < currentIndex {
            return geometry.size.width // Completed
        } else if index == currentIndex {
            return geometry.size.width * progress // Current
        } else {
            return 0 // Not started
        }
    }
    
    // MARK: - Timer Functions
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if !isPaused {
                progress += 0.05 / storyDuration
                
                if progress >= 1.0 {
                    nextStory()
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func pauseTimer() {
        isPaused = true
    }
    
    private func resumeTimer() {
        isPaused = false
    }
    
    // MARK: - Navigation
    private func nextStory() {
        if currentIndex < stories.count - 1 {
            currentIndex += 1
            progress = 0
        } else {
            dismiss()
        }
    }
    
    private func previousStory() {
        if currentIndex > 0 {
            currentIndex -= 1
            progress = 0
        }
    }
    
    // MARK: - Load Story
    private func loadCurrentStory() {
        guard let story = currentStory else {
            return
        }
        
        isLoading = true
        cachedImage = nil
        
        Task {
            do {
                let image = try await ImageCacheService.shared.loadImage(from: story.photoURL, thumbnail: false)
                await MainActor.run {
                    cachedImage = image
                    isLoading = false
                }
            } catch {
                print("❌ Story resmi yüklenemedi: \(error.localizedDescription)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
    
    // MARK: - Mark as Viewed
    private func markAsViewed() {
        guard let story = currentStory,
              let userId = authService.currentUser?.id,
              let storyId = story.id,
              !story.isViewedBy(userId: userId) else {
            return
        }
        
        Task {
            try? await storyService.markStoryAsViewed(storyId: storyId, userId: userId)
        }
    }
    
    // MARK: - Delete Story
    private func deleteCurrentStory() {
        guard let story = currentStory,
              let storyId = story.id else {
            return
        }
        
        Task {
            do {
                try await storyService.deleteStory(storyId: storyId)
                
                await MainActor.run {
                    // Eğer başka story varsa ona geç, yoksa kapat
                    if stories.count > 1 {
                        if currentIndex < stories.count - 1 {
                            // Sonraki story'ye geç
                            nextStory()
                        } else if currentIndex > 0 {
                            // Önceki story'ye geç
                            previousStory()
                        } else {
                            // Tek story vardı, kapat
                            dismiss()
                        }
                    } else {
                        // Son story'ydi, kapat
                        dismiss()
                    }
                }
            } catch {
                print("❌ Story silinemedi: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Cached Avatar View
struct CachedAvatarView: View {
    let photoURL: String?
    let size: CGFloat
    
    @State private var cachedImage: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let image = cachedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(LinearGradient(
                        colors: [.pink, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: size, height: size)
                    .overlay {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                                .font(.system(size: size * 0.5))
                        }
                    }
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let photoURL = photoURL else {
            isLoading = false
            return
        }
        
        Task {
            do {
                let image = try await ImageCacheService.shared.loadImage(from: photoURL, thumbnail: true)
                await MainActor.run {
                    cachedImage = image
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}
