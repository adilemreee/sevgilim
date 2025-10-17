//
//  StoryService.swift
//  sevgilim
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseStorage
import UIKit

class StoryService: ObservableObject {
    @Published var stories: [Story] = []
    @Published var userStories: [Story] = [] // Kullanıcının tüm story'leri
    @Published var partnerStories: [Story] = [] // Partner'ın tüm story'leri
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var listener: ListenerRegistration?
    
    // Story'leri dinle (real-time)
    func listenToStories(relationshipId: String, currentUserId: String) {
        listener?.remove()
        
        listener = db.collection("stories")
            .whereField("relationshipId", isEqualTo: relationshipId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Story dinleme hatası: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                // Story'leri parse et
                var fetchedStories: [Story] = []
                for doc in documents {
                    if let story = try? doc.data(as: Story.self) {
                        fetchedStories.append(story)
                    }
                }
                
                // Süresi dolmuşları sil (background task)
                for story in fetchedStories where story.isExpired {
                    Task {
                        try? await self.deleteStory(storyId: story.id ?? "")
                    }
                }
                
                // Aktif story'leri filtrele
                let activeStories = fetchedStories.filter { !$0.isExpired }
                
                DispatchQueue.main.async {
                    self.stories = activeStories
                    
                    // User ve partner story'lerini ayır (array olarak)
                    self.userStories = activeStories.filter { $0.createdBy == currentUserId }
                        .sorted { $0.createdAt > $1.createdAt } // Yeniden eskiye
                    self.partnerStories = activeStories.filter { $0.createdBy != currentUserId }
                        .sorted { $0.createdAt > $1.createdAt } // Yeniden eskiye
                }
            }
    }
    
    // Story yükle
    func uploadStory(
        relationshipId: String,
        userId: String,
        userName: String,
        userPhotoURL: String?,
        image: UIImage
    ) async throws -> Story {
        // Önce fotoğrafı upload et
        let photoURL = try await uploadStoryImage(image: image, relationshipId: relationshipId, userId: userId)
        
        // Thumbnail oluştur ve upload et
        let thumbnailURL = try? await uploadStoryThumbnail(image: image, relationshipId: relationshipId, userId: userId)
        
        // Story oluştur
        let story = Story(
            photoURL: photoURL,
            thumbnailURL: thumbnailURL,
            createdBy: userId,
            createdByName: userName,
            createdByPhotoURL: userPhotoURL,
            relationshipId: relationshipId,
            createdAt: Date(),
            viewedBy: [userId] // Oluşturan kişi otomatik görülmüş sayılır
        )
        
        // Firestore'a kaydet
        let docRef = try db.collection("stories").addDocument(from: story)
        
        var savedStory = story
        savedStory.id = docRef.documentID
        
        return savedStory
    }
    
    // Story fotoğrafını upload et
    private func uploadStoryImage(image: UIImage, relationshipId: String, userId: String) async throws -> String {
        // Resmi optimize et
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "StoryService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Resim verisi oluşturulamadı"])
        }
        
        // Storage path
        let timestamp = Int(Date().timeIntervalSince1970)
        let fileName = "story_\(userId)_\(timestamp).jpg"
        let storagePath = "relationships/\(relationshipId)/stories/\(fileName)"
        let storageRef = storage.reference().child(storagePath)
        
        // Upload
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        
        // Download URL al
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }
    
    // Story thumbnail'ı upload et
    private func uploadStoryThumbnail(image: UIImage, relationshipId: String, userId: String) async throws -> String {
        // Thumbnail boyutu (200x200)
        let thumbnailSize = CGSize(width: 200, height: 200)
        
        UIGraphicsBeginImageContextWithOptions(thumbnailSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: thumbnailSize))
        guard let thumbnail = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            throw NSError(domain: "StoryService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Thumbnail oluşturulamadı"])
        }
        UIGraphicsEndImageContext()
        
        guard let thumbnailData = thumbnail.jpegData(compressionQuality: 0.6) else {
            throw NSError(domain: "StoryService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Thumbnail verisi oluşturulamadı"])
        }
        
        // Storage path
        let timestamp = Int(Date().timeIntervalSince1970)
        let fileName = "story_thumb_\(userId)_\(timestamp).jpg"
        let storagePath = "relationships/\(relationshipId)/stories/thumbnails/\(fileName)"
        let storageRef = storage.reference().child(storagePath)
        
        // Upload
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await storageRef.putDataAsync(thumbnailData, metadata: metadata)
        
        // Download URL al
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }
    
    // Story'yi görüldü olarak işaretle
    func markStoryAsViewed(storyId: String, userId: String) async throws {
        let storyRef = db.collection("stories").document(storyId)
        
        // viewedBy array'ine ekle (duplicate kontrolü Firestore'da)
        try await storyRef.updateData([
            "viewedBy": FieldValue.arrayUnion([userId])
        ])
    }
    
    // Story sil
    func deleteStory(storyId: String) async throws {
        // Önce story'yi al (fotoğrafları silmek için)
        let storyRef = db.collection("stories").document(storyId)
        let document = try await storyRef.getDocument()
        
        if let story = try? document.data(as: Story.self) {
            // Storage'dan fotoğrafı sil
            if URL(string: story.photoURL) != nil {
                let photoRef = storage.reference(forURL: story.photoURL)
                try? await photoRef.delete()
            }
            
            // Thumbnail'ı sil
            if let thumbnailURL = story.thumbnailURL,
               URL(string: thumbnailURL) != nil {
                let thumbRef = storage.reference(forURL: thumbnailURL)
                try? await thumbRef.delete()
            }
        }
        
        // Firestore'dan sil
        try await storyRef.delete()
    }
    
    // Kullanıcının story'sini sil
    func deleteUserStory(userId: String) async throws {
        let userStories = userStories.filter { $0.createdBy == userId }
        for story in userStories {
            try await deleteStory(storyId: story.id ?? "")
        }
    }
    
    // Tüm süresi dolmuş story'leri sil
    func deleteExpiredStories(relationshipId: String) async throws {
        let snapshot = try await db.collection("stories")
            .whereField("relationshipId", isEqualTo: relationshipId)
            .getDocuments()
        
        for document in snapshot.documents {
            if let story = try? document.data(as: Story.self), story.isExpired {
                try await deleteStory(storyId: story.id ?? "")
            }
        }
    }
    
    // Listener'ı durdur
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    deinit {
        stopListening()
    }
}
