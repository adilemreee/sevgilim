//
//  PlaceService.swift
//  sevgilim
//

import Foundation
import Combine
import FirebaseFirestore

@MainActor
class PlaceService: ObservableObject {
    @Published var places: [Place] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let placesLimit = 50 // Load first 50 places for performance
    
    func listenToPlaces(relationshipId: String) {
        listener?.remove()
        isLoading = true
        
        // Optimized query: limit results for faster loading
        listener = db.collection("places")
            .whereField("relationshipId", isEqualTo: relationshipId)
            .limit(to: placesLimit)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Error listening to places: \(error.localizedDescription)")
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
                
                // Process only changed documents for better performance
                let newPlaces = documents.compactMap { doc -> Place? in
                    try? doc.data(as: Place.self)
                }
                
                // Client-side sorting: En yeni tarihler üstte
                let sortedPlaces = newPlaces.sorted { $0.date > $1.date }
                
                Task { @MainActor in
                    self.places = sortedPlaces
                    self.isLoading = false
                }
            }
    }
    
    func addPlace(
        relationshipId: String,
        name: String,
        address: String?,
        latitude: Double,
        longitude: Double,
        note: String?,
        photoURLs: [String]?,
        date: Date,
        userId: String
    ) async throws {
        let place = Place(
            relationshipId: relationshipId,
            name: name,
            address: address,
            latitude: latitude,
            longitude: longitude,
            note: note,
            photoURLs: photoURLs,
            date: date,
            addedBy: userId,
            createdAt: Date()
        )
        
        let _ = try db.collection("places").addDocument(from: place)
    }
    
    func updatePlace(_ place: Place) async throws {
        guard let id = place.id else { return }
        
        try db.collection("places").document(id).setData(from: place)
    }
    
    func deletePlace(_ place: Place) async throws {
        guard let id = place.id else { return }
        
        try await db.collection("places").document(id).delete()
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    deinit {
        listener?.remove()
        listener = nil
    }
}
