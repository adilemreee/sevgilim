//
//  HomeView.swift
//  sevgilim
//

import SwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var relationshipService: RelationshipService
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var photoService: PhotoService
    @EnvironmentObject var memoryService: MemoryService
    @EnvironmentObject var noteService: NoteService
    @EnvironmentObject var planService: PlanService
    @EnvironmentObject var movieService: MovieService
    @EnvironmentObject var placeService: PlaceService
    @EnvironmentObject var songService: SongService
    
    @State private var currentDate = Date()
    @State private var animateHearts = false
    @State private var showingMenu = false
    @State private var navigateToPlans = false
    @State private var navigateToMovies = false
    @State private var navigateToChat = false
    @State private var navigateToPlaces = false
    @State private var navigateToSongs = false
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated gradient background
                AnimatedGradientBackground(theme: themeManager.currentTheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        if let relationship = relationshipService.currentRelationship,
                           let _ = authService.currentUser {
                            
                            // Modern Couple Header
                            CoupleHeaderCard(
                                user1Name: relationship.user1Name,
                                user2Name: relationship.user2Name,
                                animateHearts: $animateHearts
                            )
                            
                            // Day Counter Card
                            DayCounterCard(
                                startDate: relationship.startDate,
                                currentDate: currentDate,
                                theme: themeManager.currentTheme
                            )
                            
                            // Quick Stats
                            QuickStatsGrid(
                                photosCount: photoService.photos.count,
                                memoriesCount: memoryService.memories.count,
                                notesCount: noteService.notes.count,
                                plansCount: planService.plans.count,
                                theme: themeManager.currentTheme
                            )
                            
                            // Recent Memories Preview
                            if !memoryService.memories.isEmpty {
                                RecentMemoriesCard(
                                    memories: Array(memoryService.memories.prefix(3))
                                )
                            }
                            
                            // Upcoming Plans
                            if !planService.plans.filter({ !$0.isCompleted }).isEmpty {
                                UpcomingPlansCard(
                                    plans: Array(planService.plans.filter { !$0.isCompleted }.prefix(3))
                                )
                            }
                            
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingMenu = true }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $navigateToPlans) {
                PlansView()
            }
            .navigationDestination(isPresented: $navigateToMovies) {
                MoviesView()
            }
            .navigationDestination(isPresented: $navigateToChat) {
                ChatView()
            }
            .navigationDestination(isPresented: $navigateToPlaces) {
                PlacesView()
            }
            .navigationDestination(isPresented: $navigateToSongs) {
                SongsView()
            }
            .sheet(isPresented: $showingMenu) {
                HamburgerMenuView(
                    onPlansSelected: {
                        showingMenu = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            navigateToPlans = true
                        }
                    },
                    onMoviesSelected: {
                        showingMenu = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            navigateToMovies = true
                        }
                    },
                    onChatSelected: {
                        showingMenu = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            navigateToChat = true
                        }
                    },
                    onPlacesSelected: {
                        showingMenu = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            navigateToPlaces = true
                        }
                    },
                    onSongsSelected: {
                        showingMenu = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            navigateToSongs = true
                        }
                    }
                )
                .environmentObject(themeManager)
                .environmentObject(planService)
                .environmentObject(movieService)
                .environmentObject(placeService)
                .environmentObject(songService)
                .presentationDetents([.height(450)])
                .presentationDragIndicator(.visible)
            }
            .onReceive(timer) { _ in
                currentDate = Date()
            }
            .task {
                // Use task for better lifecycle management
                if let relationshipId = authService.currentUser?.relationshipId {
                    relationshipService.listenToRelationship(relationshipId: relationshipId)
                }
                
                // Start heart animation
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    animateHearts = true
                }
            }
        }
    }
}

// MARK: - Couple Header
struct CoupleHeaderCard: View {
    let user1Name: String
    let user2Name: String
    @Binding var animateHearts: Bool
    @State private var tapAnimations: [TapHeartAnimation] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sevgilimmm")
                .font(.system(size: 45, weight: .thin, design: .rounded))
                .foregroundColor(.white)
            
            HStack(spacing: 25) {
                Text(user1Name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                ZStack {
                    // Otomatik kalp animasyonu
                    Image(systemName: "heart.fill")
                        .font(.title)
                        .foregroundColor(.red)
                        .scaleEffect(animateHearts ? 1.15 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateHearts)
                    
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                            .foregroundColor(.pink.opacity(0.7))
                            .offset(
                                x: [0, -25, 25][index],
                                y: animateHearts ? -30 : 0
                            )
                            .opacity(animateHearts ? 0 : 1)
                            .animation(
                                .easeOut(duration: 2)
                                .delay(Double(index) * 0.3)
                                .repeatForever(autoreverses: false),
                                value: animateHearts
                            )
                    }
                    
                    // Tıklama animasyonları
                    ForEach(tapAnimations) { animation in
                        TapHeartView(animation: animation)
                    }
                }
                .onTapGesture {
                    createTapAnimation()
                }
                
                Text(user2Name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }
    
    private func createTapAnimation() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Her tıklamada 8 kalp oluştur
        let heartCount = 8
        for i in 0..<heartCount {
            let angle = (Double(i) / Double(heartCount)) * 360.0
            let animation = TapHeartAnimation(
                id: UUID(),
                angle: angle,
                color: [Color.red, Color.pink, Color.purple, Color.orange].randomElement() ?? .red
            )
            tapAnimations.append(animation)
        }
        
        // 1.5 saniye sonra animasyonları temizle
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            tapAnimations.removeAll()
        }
    }
}

// MARK: - Tap Heart Animation Models
struct TapHeartAnimation: Identifiable {
    let id: UUID
    let angle: Double
    let color: Color
}

struct TapHeartView: View {
    let animation: TapHeartAnimation
    @State private var isAnimating = false
    
    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 20))
            .foregroundColor(animation.color)
            .offset(
                x: isAnimating ? cos(animation.angle * .pi / 180) * 80 : 0,
                y: isAnimating ? sin(animation.angle * .pi / 180) * 80 : 0
            )
            .scaleEffect(isAnimating ? 1.5 : 0.5)
            .opacity(isAnimating ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: 1.2)) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Day Counter
struct DayCounterCard: View {
    let startDate: Date
    let currentDate: Date
    let theme: AppTheme
    
    var daysSince: Int {
        startDate.daysBetween(currentDate)
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Birlikte Geçirdiğimiz Zaman")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("\(daysSince)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("GÜN")
                .font(.title3.bold())
                .foregroundColor(.white.opacity(0.8))
            
            Text(currentDate.formattedDifference(from: startDate))
                .font(.title3)
                .foregroundColor(.white.opacity(0.7))
            
            Text("Başlangıç: \(startDate, formatter: DateFormatter.displayFormat)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
    }
}

// MARK: - Quick Stats
struct QuickStatsGrid: View {
    let photosCount: Int
    let memoriesCount: Int
    let notesCount: Int
    let plansCount: Int
    let theme: AppTheme
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 15) {
            StatCardModern(
                title: "Fotoğraflar",
                value: "\(photosCount)",
                icon: "photo.stack.fill",
                color: .blue
            )
            
            StatCardModern(
                title: "Anılar",
                value: "\(memoriesCount)",
                icon: "heart.text.square.fill",
                color: .pink
            )
            
            StatCardModern(
                title: "Notlar",
                value: "\(notesCount)",
                icon: "note.text",
                color: .orange
            )
            
            StatCardModern(
                title: "Planlar",
                value: "\(plansCount)",
                icon: "list.star",
                color: .purple
            )
        }
    }
}

struct StatCardModern: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @State private var animateCard = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
        .scaleEffect(animateCard ? 1.05 : 1.0)
        .onTapGesture {
            // Lightweight animation
            withAnimation(.easeInOut(duration: 0.15)) {
                animateCard = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    animateCard = false
                }
            }
        }
    }
}

// MARK: - Recent Memories
struct RecentMemoriesCard: View {
    let memories: [Memory]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Son Anılarımız")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "heart.text.square")
                    .foregroundColor(.white.opacity(0.7))
            }
            
            VStack(spacing: 8) {
                ForEach(memories) { memory in
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(.white.opacity(0.7))
                        Text(memory.title)
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .lineLimit(1)
                        Spacer()
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Upcoming Plans
struct UpcomingPlansCard: View {
    let plans: [Plan]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Yaklaşan Planlarımız")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "calendar")
                    .foregroundColor(.white.opacity(0.7))
            }
            
            VStack(spacing: 8) {
                ForEach(plans) { plan in
                    HStack {
                        Image(systemName: "circle")
                            .foregroundColor(.white.opacity(0.7))
                        Text(plan.title)
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .lineLimit(1)
                        Spacer()
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}


// MARK: - Profile Button with Caching
struct ProfileButton: View {
    let profileImageURL: String?
    
    var body: some View {
        Group {
            if let urlString = profileImageURL {
                CachedAsyncImage(url: urlString, thumbnail: true) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                } placeholder: {
                    defaultProfileIcon
                }
            } else {
                defaultProfileIcon
            }
        }
    }
    
    private var defaultProfileIcon: some View {
        Image(systemName: "person.circle.fill")
            .font(.system(size: 40))
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Hamburger Menu View
struct HamburgerMenuView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var planService: PlanService
    @EnvironmentObject var movieService: MovieService
    @EnvironmentObject var placeService: PlaceService
    @EnvironmentObject var songService: SongService
    
    let onPlansSelected: () -> Void
    let onMoviesSelected: () -> Void
    let onChatSelected: () -> Void
    let onPlacesSelected: () -> Void
    let onSongsSelected: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag Handle
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 8)
            
            // Header
            VStack(spacing: 4) {
                Text("Menü")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [themeManager.currentTheme.primaryColor, themeManager.currentTheme.accentColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("AŞKIMSIN 🧡")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
            
            // Menu Items - Minimal Design
            VStack(spacing: 1) {
                MinimalMenuButton(
                    icon: "message.fill",
                    title: "Sohbet",
                    theme: themeManager.currentTheme,
                    action: onChatSelected
                )
                
                MinimalMenuButton(
                    icon: "calendar",
                    title: "Planlar",
                    count: planService.plans.count,
                    theme: themeManager.currentTheme,
                    action: onPlansSelected
                )
                
                MinimalMenuButton(
                    icon: "film.fill",
                    title: "Filmler",
                    count: movieService.movies.count,
                    theme: themeManager.currentTheme,
                    action: onMoviesSelected
                )
                
                MinimalMenuButton(
                    icon: "map.fill",
                    title: "Yerler",
                    count: placeService.places.count,
                    theme: themeManager.currentTheme,
                    action: onPlacesSelected
                )
                
                MinimalMenuButton(
                    icon: "music.note.list",
                    title: "Şarkılar",
                    count: songService.songs.count,
                    theme: themeManager.currentTheme,
                    action: onSongsSelected
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
}

struct MinimalMenuButton: View {
    let icon: String
    let title: String
    var count: Int?
    let theme: AppTheme
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(theme.primaryColor)
                    .frame(width: 24)
                
                // Title
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Count Badge (if available)
                if let count = count, count > 0 {
                    Text("\(count)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.primaryColor.opacity(0.8))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(theme.primaryColor.opacity(0.12))
                        .clipShape(Capsule())
                }
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isPressed ? Color(.systemGray6) : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color(.systemGray5).opacity(0.5), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

