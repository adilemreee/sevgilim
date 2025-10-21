//
//  sevgilimApp.swift
//  sevgilim
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import UserNotifications

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
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()

        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        requestNotificationPermissions(for: application)
        PushNotificationManager.shared.refreshIfNeeded()

        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ APNs kayıt hatası: \(error.localizedDescription)")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        PushNotificationManager.shared.syncTokenWithCurrentUser()
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        PushNotificationManager.shared.updateFCMToken(token)
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        updateBadge(using: notification.request.content.userInfo)
        completionHandler([.banner, .list, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        updateBadge(using: response.notification.request.content.userInfo)
        NotificationCenter.default.post(
            name: .didReceiveRemoteNotification,
            object: nil,
            userInfo: response.notification.request.content.userInfo
        )
        completionHandler()
    }

    private func requestNotificationPermissions(for application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("❌ Bildirim izni hatası: \(error.localizedDescription)")
                return
            }

            guard granted else {
                print("ℹ️ Kullanıcı bildirim izni vermedi.")
                return
            }

            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
    
    private func updateBadge(using userInfo: [AnyHashable: Any]) {
        let updateBlock = {
            let application = UIApplication.shared
            
            if let aps = userInfo["aps"] as? [String: Any],
               let badgeValue = aps["badge"] as? Int {
                application.applicationIconBadgeNumber = badgeValue
            } else {
                let newValue = max(application.applicationIconBadgeNumber + 1, 1)
                application.applicationIconBadgeNumber = newValue
            }
        }
        
        if Thread.isMainThread {
            updateBlock()
        } else {
            DispatchQueue.main.async {
                updateBlock()
            }
        }
    }
}

extension Notification.Name {
    static let didReceiveRemoteNotification = Notification.Name("didReceiveRemoteNotification")
}
