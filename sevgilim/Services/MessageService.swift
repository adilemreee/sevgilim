//
//  MessageService.swift
//  sevgilim
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseStorage

@MainActor
class MessageService: ObservableObject {
    @Published var messages: [Message] = []
    @Published var partnerIsTyping: Bool = false
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var messagesListener: ListenerRegistration?
    private var typingListener: ListenerRegistration?
    private var typingTimer: Timer?
    
    // MARK: - Listen to Messages (Optimized)
    func listenToMessages(relationshipId: String) {
        // Remove existing listener if any
        messagesListener?.remove()
        
        // Load recent messages only for better performance
        messagesListener = db.collection("messages")
            .whereField("relationshipId", isEqualTo: relationshipId)
            .limit(to: 100) // Load last 100 messages
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Error listening to messages: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    return
                }
                
                self.messages = documents.compactMap { document in
                    try? document.data(as: Message.self)
                }
                
                // Client-side sorting by timestamp (newest at bottom)
                self.messages.sort { $0.timestamp < $1.timestamp }
            }
    }
    
    // MARK: - Listen to Typing Indicator
    func listenToTypingIndicator(relationshipId: String, currentUserId: String) {
        print("⌨️ Starting to listen to typing indicator")
        
        typingListener?.remove()
        
        typingListener = db.collection("relationships")
            .document(relationshipId)
            .collection("typing")
            .document("current")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Error listening to typing: \(error.localizedDescription)")
                    return
                }
                
                guard let data = snapshot?.data(),
                      let userId = data["userId"] as? String,
                      let isTyping = data["isTyping"] as? Bool,
                      let timestamp = data["timestamp"] as? Timestamp else {
                    self.partnerIsTyping = false
                    return
                }
                
                // Convert Firestore Timestamp to Date
                let date = timestamp.dateValue()
                
                // Only show typing if it's not the current user and was updated recently (within 3 seconds)
                let isRecent = Date().timeIntervalSince(date) < 3
                self.partnerIsTyping = userId != currentUserId && isTyping && isRecent
                
                print("⌨️ Partner typing: \(self.partnerIsTyping)")
            }
    }
    
    // MARK: - Send Message
    func sendMessage(relationshipId: String, senderId: String, senderName: String, text: String) async throws {
        print("💬 Sending message: \(text)")
        
        let message = Message(
            relationshipId: relationshipId,
            senderId: senderId,
            senderName: senderName,
            text: text,
            imageURL: nil,
            timestamp: Date(),
            isRead: false,
            readAt: nil
        )
        
        do {
            let _ = try db.collection("messages").addDocument(from: message)
            print("✅ Message sent successfully")
            
            // Clear typing indicator
            try await setTypingIndicator(relationshipId: relationshipId, userId: senderId, userName: senderName, isTyping: false)
        } catch {
            print("❌ Error sending message: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Send Message with Image
    func sendMessageWithImage(relationshipId: String, senderId: String, senderName: String, text: String, image: UIImage) async throws {
        print("📸 Uploading image for message")
        
        do {
            // Use optimized StorageService for upload
            let imagePath = "relationships/\(relationshipId)/messages/\(UUID().uuidString).jpg"
            let imageURL = try await StorageService.shared.uploadImage(image, path: imagePath, quality: 0.7)
            
            print("✅ Image uploaded: \(imageURL)")
            
            // Send message with image URL
            let message = Message(
                relationshipId: relationshipId,
                senderId: senderId,
                senderName: senderName,
                text: text.isEmpty ? "📷 Fotoğraf" : text,
                imageURL: imageURL,
                timestamp: Date(),
                isRead: false,
                readAt: nil
            )
            
            let _ = try db.collection("messages").addDocument(from: message)
            print("✅ Message with image sent successfully")
            
            // Clear typing indicator
            try await setTypingIndicator(relationshipId: relationshipId, userId: senderId, userName: senderName, isTyping: false)
        } catch {
            print("❌ Error sending message with image: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Mark as Read
    func markAsRead(messageId: String) async throws {
        print("✓ Marking message as read: \(messageId)")
        
        do {
            try await db.collection("messages").document(messageId).updateData([
                "isRead": true,
                "readAt": FieldValue.serverTimestamp()
            ])
            print("✅ Message marked as read")
        } catch {
            print("❌ Error marking message as read: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Set Typing Indicator
    func setTypingIndicator(relationshipId: String, userId: String, userName: String, isTyping: Bool) async throws {
        let data: [String: Any] = [
            "userId": userId,
            "userName": userName,
            "isTyping": isTyping,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        do {
            try await db.collection("relationships")
                .document(relationshipId)
                .collection("typing")
                .document("current")
                .setData(data)
        } catch {
            print("❌ Error setting typing indicator: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Start Typing
    func startTyping(relationshipId: String, userId: String, userName: String) {
        Task {
            try? await setTypingIndicator(relationshipId: relationshipId, userId: userId, userName: userName, isTyping: true)
        }
        
        // Auto-clear typing after 3 seconds
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                try? await self?.setTypingIndicator(relationshipId: relationshipId, userId: userId, userName: userName, isTyping: false)
            }
        }
    }
    
    // MARK: - Stop Typing
    func stopTyping(relationshipId: String, userId: String, userName: String) {
        typingTimer?.invalidate()
        Task {
            try? await setTypingIndicator(relationshipId: relationshipId, userId: userId, userName: userName, isTyping: false)
        }
    }
    
    // MARK: - Cleanup
    func cleanup() {
        print("🧹 Cleaning up MessageService")
        messagesListener?.remove()
        typingListener?.remove()
        typingTimer?.invalidate()
    }
    
    nonisolated deinit {
        // Cancel listeners synchronously (safe in deinit)
        messagesListener?.remove()
        typingListener?.remove()
        typingTimer?.invalidate()
    }
}

