//
//  PushNotificationManager.swift
//  sevgilim
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging

final class PushNotificationManager {
    static let shared = PushNotificationManager()

    private let db = Firestore.firestore()
    private let tokenDefaultsKey = "cachedFCMToken"
    private let queue = DispatchQueue(label: "PushNotificationManager.queue")

    private init() {}

    private var cachedToken: String? {
        get { UserDefaults.standard.string(forKey: tokenDefaultsKey) }
        set {
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: tokenDefaultsKey)
            } else {
                UserDefaults.standard.removeObject(forKey: tokenDefaultsKey)
            }
        }
    }

    func updateFCMToken(_ token: String) {
        guard !token.isEmpty else { return }

        queue.async {
            let previousToken = self.cachedToken

            if previousToken == token {
                self.syncTokenWithCurrentUser()
                return
            }

            self.cachedToken = token

            if let previousToken {
                self.removeTokenFromCurrentUser(previousToken)
            }

            self.syncTokenWithCurrentUser()
        }
    }

    func refreshIfNeeded() {
        Messaging.messaging().token { [weak self] token, error in
            if let error = error {
                print("❌ FCM token alınamadı: \(error.localizedDescription)")
                return
            }

            guard let token = token else { return }
            self?.updateFCMToken(token)
        }
    }

    func syncTokenWithCurrentUser() {
        guard let token = cachedToken,
              let userId = Auth.auth().currentUser?.uid else { return }

        Task {
            do {
                try await db.collection("users").document(userId).setData([
                    "fcmTokens": FieldValue.arrayUnion([token]),
                    "fcmUpdatedAt": FieldValue.serverTimestamp()
                ], merge: true)
            } catch {
                print("❌ FCM token Firestore'a yazılamadı: \(error.localizedDescription)")
            }
        }
    }

    func unregisterCurrentToken() {
        guard let token = cachedToken,
              let userId = Auth.auth().currentUser?.uid else { return }

        Task {
            do {
                try await db.collection("users").document(userId).updateData([
                    "fcmTokens": FieldValue.arrayRemove([token])
                ])
            } catch {
                print("❌ FCM token silinemedi: \(error.localizedDescription)")
            }
        }
    }

    private func removeTokenFromCurrentUser(_ token: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        Task {
            do {
                try await db.collection("users").document(userId).updateData([
                    "fcmTokens": FieldValue.arrayRemove([token])
                ])
            } catch {
                print("❌ Eski FCM token kaldırılamadı: \(error.localizedDescription)")
            }
        }
    }
}
