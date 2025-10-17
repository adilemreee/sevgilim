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
    @EnvironmentObject var surpriseService: SurpriseService
    
    @State private var currentDate = Date()
    @State private var animateHearts = false
    @State private var showingMenu = false
    @State private var navigateToPlans = false
    @State private var navigateToMovies = false
    @State private var navigateToChat = false
    @State private var navigateToPlaces = false
    @State private var navigateToSongs = false
    @State private var navigateToSurprises = false
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
                            
                            // Dinamik Selamlama Widget (Sadece belirli saatlerde)
                            if shouldShowGreeting(for: currentDate) {
                                GreetingCard(currentDate: currentDate)
                            }
                            
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
                            
                            // Partner Surprise Card
                            if let currentUser = authService.currentUser,
                               let userId = currentUser.id,
                               let surprise = surpriseService.nextUpcomingSurpriseForUser(userId: userId) {
                                PartnerSurpriseHomeCard(
                                    surprise: surprise,
                                    onTap: {
                                        navigateToSurprises = true
                                    },
                                    onOpen: {
                                        Task {
                                            try? await surpriseService.markAsOpened(surprise)
                                        }
                                    }
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
            .navigationDestination(isPresented: $navigateToSurprises) {
                SurprisesView()
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
                    },
                    onSurprisesSelected: {
                        showingMenu = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            navigateToSurprises = true
                        }
                    }
                )
                .environmentObject(themeManager)
                .environmentObject(planService)
                .environmentObject(movieService)
                .environmentObject(placeService)
                .environmentObject(songService)
                .environmentObject(surpriseService)
                .presentationDetents([.height(500)])
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
    
    // Selamlama widget'ının gösterilip gösterilmeyeceğini kontrol eder
    private func shouldShowGreeting(for date: Date) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)
        // Sadece gece 23:00 - sabah 12:00 arası göster
        return (hour >= 23 || hour < 12)
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

// MARK: - Greeting Card
struct GreetingCard: View {
    let currentDate: Date
    
    var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: currentDate)
        // Sabah 7:00 - 12:00: Günaydın
        // Gece 23:00 - Sabah 7:00: İyi Geceler
        if hour >= 7 && hour < 12 {
            return "Günaydın aşkımmmm"
        } else {
            return "İyi Geceler sevgilimmmm"
        }
    }
    
    var greetingIcon: String {
        let hour = Calendar.current.component(.hour, from: currentDate)
        if hour >= 7 && hour < 12 {
            return "sun.max.fill"
        } else {
            return "moon.stars.fill"
        }
    }
    
    var greetingColor: Color {
        let hour = Calendar.current.component(.hour, from: currentDate)
        if hour >= 7 && hour < 12 {
            return .orange
        } else {
            return .indigo
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: greetingIcon)
                .font(.system(size: 24))
                .foregroundStyle(
                    greetingColor.gradient
                )
                .shadow(color: greetingColor.opacity(0.5), radius: 4)
            
            Text(greetingMessage)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [
                    greetingColor.opacity(0.3),
                    greetingColor.opacity(0.15)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: greetingColor.opacity(0.2), radius: 10, x: 0, y: 5)
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
        VStack(spacing: 12) {
            Text("Birlikte Geçirdiğimiz Zaman")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Text("\(daysSince)")
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("GÜN")
                .font(.callout.bold())
                .foregroundColor(.white.opacity(0.8))
            
            Text(currentDate.formattedDifference(from: startDate))
                .font(.callout)
                .foregroundColor(.white.opacity(0.7))
            
            Text("Başlangıç: \(startDate, formatter: DateFormatter.displayFormat)")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
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
    @EnvironmentObject var surpriseService: SurpriseService
    
    let onPlansSelected: () -> Void
    let onMoviesSelected: () -> Void
    let onChatSelected: () -> Void
    let onPlacesSelected: () -> Void
    let onSongsSelected: () -> Void
    let onSurprisesSelected: () -> Void
    
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
            VStack(spacing: 12) {
                MinimalMenuButton(
                    icon: "message.fill",
                    title: "Sohbet",
                    theme: themeManager.currentTheme,
                    action: onChatSelected
                )
                
                MinimalMenuButton(
                    icon: "gift.fill",
                    title: "Sürprizler",
                    count: surpriseService.surprises.count,
                    theme: themeManager.currentTheme,
                    action: onSurprisesSelected
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


// MARK: - Partner Surprise Home Card
struct PartnerSurpriseHomeCard: View {
    let surprise: Surprise
    let onTap: () -> Void
    let onOpen: () -> Void
    
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showConfetti = false
    @State private var pulseAnimation = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Header
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "gift.fill")
                            .font(.body)
                            .foregroundColor(.pink)
                        Text(surprise.isLocked ? "Gizli Sürpriz" : (surprise.shouldReveal ? "Sürpriz Hazır!" : surprise.title))
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.horizontal, 20)
                
                // Content
                if surprise.isLocked {
                    // Kilitli - Kompakt Geri Sayım
                    VStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                            Text("İçeriği görmek için zamanı bekle!")
                                .font(.caption)
                        }
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 12)
                        
                        Text("Açılışa Kalan Süre")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.top, 4)
                        
                        // Kompakt geri sayım
                        HStack(spacing: 12) {
                            TimeUnitCompactSmall(value: days, unit: "Gün")
                            Text(":")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.title3)
                            TimeUnitCompactSmall(value: hours, unit: "Saat")
                            Text(":")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.title3)
                            TimeUnitCompactSmall(value: minutes, unit: "Dk")
                            Text(":")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.title3)
                            TimeUnitCompactSmall(value: seconds, unit: "Sn")
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.bottom, 16)
                } else if surprise.shouldReveal && !surprise.isOpened {
                    // Açılmaya Hazır
                    VStack(spacing: 8) {
                        Text("🎉 Sürprizi açmak için dokun!")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.vertical, 12)
                    }
                    .padding(.bottom, 16)
                } else {
                    // Açılmış
                    VStack(spacing: 6) {
                        Text("Açılmış Sürpriz")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.vertical, 12)
                    }
                    .padding(.bottom, 16)
                }
            }
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .confetti(isActive: showConfetti)
        .onAppear {
            setupTimer()
            startPulseAnimation()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // MARK: - Time Unit Compact Small
    
    private struct TimeUnitCompactSmall: View {
        let value: Int
        let unit: String
        
        var body: some View {
            VStack(spacing: 2) {
                Text("\(value)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()
                
                Text(unit)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(width: 40)
        }
    }
    
    // MARK: - Computed Properties
    
    private var days: Int {
        return Int(timeRemaining) / 86400
    }
    
    private var hours: Int {
        return (Int(timeRemaining) % 86400) / 3600
    }
    
    private var minutes: Int {
        return (Int(timeRemaining) % 3600) / 60
    }
    
    private var seconds: Int {
        return Int(timeRemaining) % 60
    }
    
    // MARK: - Functions
    
    private func setupTimer() {
        timeRemaining = surprise.timeRemaining
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
            }
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(
            .easeInOut(duration: 1.5)
            .repeatForever(autoreverses: true)
        ) {
            pulseAnimation = true
        }
    }
}

