//
//  AuthenticationService.swift
//  sevgilim
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class AuthenticationService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if let firebaseUser = Auth.auth().currentUser {
            fetchUserData(userId: firebaseUser.uid)
        }
    }
    
    func signUp(email: String, password: String, name: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            let newUser = User(
                id: result.user.uid,
                email: email,
                name: name,
                profileImageURL: nil,
                relationshipId: nil,
                createdAt: Date()
            )
            
            try await db.collection("users").document(result.user.uid).setData([
                "email": email,
                "name": name,
                "createdAt": Timestamp(date: Date())
            ])
            
            await MainActor.run {
                self.currentUser = newUser
                self.isAuthenticated = true
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            fetchUserData(userId: result.user.uid)
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchUserData(userId: String) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            guard let data = snapshot?.data() else { return }
            
            let user = User(
                id: userId,
                email: data["email"] as? String ?? "",
                name: data["name"] as? String ?? "",
                profileImageURL: data["profileImageURL"] as? String,
                relationshipId: data["relationshipId"] as? String,
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            )
            
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    
    func updateUserProfile(name: String?, profileImageURL: String?) async throws {
        guard let userId = currentUser?.id else { return }
        
        var updates: [String: Any] = [:]
        if let name = name {
            updates["name"] = name
        }
        if let profileImageURL = profileImageURL {
            updates["profileImageURL"] = profileImageURL
        }
        
        try await db.collection("users").document(userId).updateData(updates)
        fetchUserData(userId: userId)
    }
    
    func updateRelationshipId(_ relationshipId: String) async throws {
        guard let userId = currentUser?.id else { return }
        
        try await db.collection("users").document(userId).updateData([
            "relationshipId": relationshipId
        ])
        
        fetchUserData(userId: userId)
    }
}

