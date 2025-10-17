//
//  sevgilimApp.swift
//  sevgilim
//

import SwiftUI
import FirebaseCore

@main
struct sevgilimApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var authService = AuthenticationService()
    @StateObject private var relationshipService = RelationshipService()
    @StateObject private var memoryService = MemoryService()
    @StateObject private var photoService = PhotoService()
    @StateObject private var noteService = NoteService()
    @StateObject private var movieService = MovieService()
    @StateObject private var planService = PlanService()
    @StateObject private var placeService = PlaceService()
    @StateObject private var songService = SongService()
    @StateObject private var spotifyService = SpotifyService()
    @StateObject private var surpriseService = SurpriseService()
    @StateObject private var specialDayService = SpecialDayService()
    @StateObject private var storyService = StoryService()
    @StateObject private var messageService = MessageService()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var greetingService = GreetingService()
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(relationshipService)
                .environmentObject(memoryService)
                .environmentObject(photoService)
                .environmentObject(noteService)
                .environmentObject(movieService)
                .environmentObject(planService)
                .environmentObject(placeService)
                .environmentObject(songService)
                .environmentObject(spotifyService)
                .environmentObject(surpriseService)
                .environmentObject(specialDayService)
                .environmentObject(storyService)
                .environmentObject(messageService)
                .environmentObject(themeManager)
                .environmentObject(greetingService)
                
        }
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        
        
        
        return true
    }
    

    
}
