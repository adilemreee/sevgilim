//
//  HomeView.swift
//  sevgilim
//
//  Refactored: Components separated for better maintainability
//  Main home screen with relationship statistics and widgets

import SwiftUI
import Combine

struct HomeView: View {
    // MARK: - Environment Objects
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
    @EnvironmentObject var specialDayService: SpecialDayService
    @EnvironmentObject var storyService: StoryService
    @EnvironmentObject var messageService: MessageService
    @EnvironmentObject var greetingService: GreetingService
    
    // MARK: - State
    @State private var currentDate = Date()
    @State private var animateHearts = false
    @State private var showingMenu = false
    @State private var navigateToPlans = false
    @State private var navigateToMovies = false
    @State private var navigateToChat = false
    @State private var navigateToPlaces = false
    @State private var navigateToSongs = false
    @State private var navigateToSurprises = false
    @State private var navigateToSpecialDays = false
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AnimatedGradientBackground(theme: themeManager.currentTheme)
                    .ignoresSafeArea()
                
                // Content
                ScrollView {
                    VStack(spacing: 30) {
                        if let relationship = relationshipService.currentRelationship,
                           let _ = authService.currentUser {
                            
                            // Couple Header
                            CoupleHeaderCard(
                                user1Name: relationship.user1Name,
                                user2Name: relationship.user2Name,
                                animateHearts: $animateHearts
                            )
                            
                            // Story Circles (Instagram-style)
                            StoryCircles()
                                .padding(.horizontal, 20)
                            
                            // Dynamic Greeting (time-based)
                            if greetingService.shouldShowGreeting {
                                GreetingCard()
                            }
                            
                            // Partner Surprise
                            if let currentUser = authService.currentUser,
                               let userId = currentUser.id,
                               let surprise = surpriseService.nextUpcomingSurpriseForUser(userId: userId) {
                                PartnerSurpriseHomeCard(
                                    surprise: surprise,
                                    onTap: { navigateToSurprises = true },
                                    onOpen: {
                                        Task {
                                            try? await surpriseService.markAsOpened(surprise)
                                        }
                                    }
                                )
                            }
                            
                            // Day Counter
                            DayCounterCard(
                                startDate: relationship.startDate,
                                currentDate: currentDate,
                                theme: themeManager.currentTheme
                            )
                            
                            // Quick Stats Grid
                            QuickStatsGrid(
                                photosCount: photoService.photos.count,
                                memoriesCount: memoryService.memories.count,
                                notesCount: noteService.notes.count,
                                plansCount: planService.plans.count,
                                theme: themeManager.currentTheme
                            )
                            
                            // Upcoming Special Day
                            if let nextDay = specialDayService.nextSpecialDay(),
                               nextDay.daysUntil <= 30 {
                                UpcomingSpecialDayWidget(
                                    specialDay: nextDay,
                                    onTap: { navigateToSpecialDays = true }
                                )
                            }
                            
                            // Recent Memories
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
                    Button {
                        showingMenu = true
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 20, weight: .semibold))
//                            .foregroundColor(.white)
                            .foregroundStyle(.white)
                    }
                        .buttonStyle(.plain)
//                    .glassEffect()
                }
            }
           .toolbarBackground(.hidden, for: .navigationBar)
            
            // Navigation Destinations
            .navigationDestination(isPresented: $navigateToPlans) { PlansView() }
            .navigationDestination(isPresented: $navigateToMovies) { MoviesView() }
            .navigationDestination(isPresented: $navigateToChat) {
                ChatView().environmentObject(messageService)
            }
            .navigationDestination(isPresented: $navigateToPlaces) { PlacesView() }
            .navigationDestination(isPresented: $navigateToSongs) { SongsView() }
            .navigationDestination(isPresented: $navigateToSurprises) { SurprisesView() }
            .navigationDestination(isPresented: $navigateToSpecialDays) { SpecialDaysView() }
            
            // Hamburger Menu Sheet
            .sheet(isPresented: $showingMenu) {
                HamburgerMenuView(
                    onPlansSelected: { navigateWithDelay(to: $navigateToPlans) },
                    onMoviesSelected: { navigateWithDelay(to: $navigateToMovies) },
                    onChatSelected: { navigateWithDelay(to: $navigateToChat) },
                    onPlacesSelected: { navigateWithDelay(to: $navigateToPlaces) },
                    onSongsSelected: { navigateWithDelay(to: $navigateToSongs) },
                    onSurprisesSelected: { navigateWithDelay(to: $navigateToSurprises) },
                    onSpecialDaysSelected: { navigateWithDelay(to: $navigateToSpecialDays) }
                )
                .environmentObject(themeManager)
                .environmentObject(planService)
                .environmentObject(movieService)
                .environmentObject(placeService)
                .environmentObject(songService)
                .environmentObject(surpriseService)
                .environmentObject(specialDayService)
                .environmentObject(messageService)
                .presentationDetents([.height(600)])
                .presentationDragIndicator(.visible)
            }
            
            // Timer & Lifecycle
            .onReceive(timer) { _ in
                currentDate = Date()
            }
            .task {
                setupServices()
                startAnimations()
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Navigate to a destination with delay (for menu dismissal animation)
    private func navigateWithDelay(to binding: Binding<Bool>) {
        showingMenu = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            binding.wrappedValue = true
        }
    }
    
    /// Setup Firebase listeners
    private func setupServices() {
        guard let relationshipId = authService.currentUser?.relationshipId,
              let userId = authService.currentUser?.id else { return } // <-- userId'yi de alın
        
        relationshipService.listenToRelationship(relationshipId: relationshipId)
        specialDayService.listenToSpecialDays(relationshipId: relationshipId)
        messageService.listenToUnreadMessagesCount(relationshipId: relationshipId, currentUserId: userId)
    }
    
    /// Start UI animations
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            animateHearts = true
        }
    }
}


