//
//  MemoryService.swift
//  sevgilim
//

import Foundation
import Combine
import FirebaseFirestore

@MainActor
class MemoryService: ObservableObject {
    @Published var memories: [Memory] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let memoriesLimit = 30 // Load first 30 memories for performance
    
    func listenToMemories(relationshipId: String) {
        listener?.remove()
        isLoading = true
        
        // Optimized query: limit results for faster loading
        listener = db.collection("memories")
            .whereField("relationshipId", isEqualTo: relationshipId)
            .limit(to: memoriesLimit)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Error listening to memories: \(error.localizedDescription)")
                    Task { @MainActor in
                        self.isLoading = false
                    }
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    Task { @MainActor in
                        self.isLoading = false
                    }
                    return
                }
                
                // Process documents efficiently
                let newMemories = documents.compactMap { doc -> Memory? in
                    try? doc.data(as: Memory.self)
                }
                
                // Client-side sorting: En yeni tarihler üstte
                let sortedMemories = newMemories.sorted { $0.date > $1.date }
                
                Task { @MainActor in
                    self.memories = sortedMemories
                    self.isLoading = false
                }
            }
    }
    
    func addMemory(relationshipId: String, title: String, content: String, 
                  date: Date, photoURL: String?, location: String?, 
                  tags: [String]?, userId: String) async throws {
        let data: [String: Any] = [
            "relationshipId": relationshipId,
            "title": title,
            "content": content,
            "date": Timestamp(date: date),
            "photoURL": photoURL as Any,
            "location": location as Any,
            "tags": tags as Any,
            "createdBy": userId,
            "createdAt": Timestamp(date: Date()),
            "likes": [],
            "comments": []
        ]
        
        try await db.collection("memories").addDocument(data: data)
    }
    
    func toggleLike(memory: Memory, userId: String) async throws {
        guard let memoryId = memory.id else { return }
        
        var updatedLikes = memory.likes
        if updatedLikes.contains(userId) {
            updatedLikes.removeAll { $0 == userId }
        } else {
            updatedLikes.append(userId)
        }
        
        // Use optimistic update for better UX
        try await db.collection("memories").document(memoryId).updateData([
            "likes": updatedLikes
        ])
    }
    
    func addComment(memory: Memory, comment: Comment) async throws {
        guard let memoryId = memory.id else { return }
        
        var updatedComments = memory.comments
        updatedComments.append(comment)
        
        let commentsData = updatedComments.map { comment in
            [
                "id": comment.id,
                "userId": comment.userId,
                "userName": comment.userName,
                "text": comment.text,
                "createdAt": Timestamp(date: comment.createdAt)
            ] as [String: Any]
        }
        
        try await db.collection("memories").document(memoryId).updateData([
            "comments": commentsData
        ])
    }
    
    func deleteMemory(_ memory: Memory) async throws {
        guard let memoryId = memory.id else { return }
        
        // Delete from Firestore first for immediate feedback
        try await db.collection("memories").document(memoryId).delete()
        
        // Delete associated photo in background
        if let photoURL = memory.photoURL {
            Task.detached(priority: .background) {
                try? await StorageService.shared.deleteImage(url: photoURL)
            }
        }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    deinit {
        listener?.remove()
    }
}

