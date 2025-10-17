//
//  PartnerSetupView.swift
//  sevgilim
//

import SwiftUI

struct PartnerSetupView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var relationshipService: RelationshipService
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var partnerEmail = ""
    @State private var startDate = Date()
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showingInvitations = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    themeManager.currentTheme.primaryColor.opacity(0.3),
                    themeManager.currentTheme.secondaryColor.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Header
                VStack(spacing: 15) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(themeManager.currentTheme.primaryColor)
                    
                    Text("Partnerinizi Ekleyin")
                        .font(.title.bold())
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    
                    Text("Birlikte anılarınızı paylaşmak için partnerinizi davet edin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 20)
                
                // Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Partner E-posta")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("partner@email.com", text: $partnerEmail)
                            .textFieldStyle(CustomTextFieldStyle())
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("İlişki Başlangıç Tarihi")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .environment(\.locale, Locale(identifier: "tr_TR"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    Button(action: sendInvitation) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Label("Davet Gönder", systemImage: "paperplane.fill")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(themeManager.currentTheme.primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(isLoading)
                }
                .padding(.horizontal, 30)
                
                // Pending Invitations
                if !relationshipService.pendingInvitations.isEmpty {
                    VStack(spacing: 15) {
                        Text("Bekleyen Davetler")
                            .font(.headline)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        
                        ForEach(relationshipService.pendingInvitations) { invitation in
                            InvitationCard(invitation: invitation)
                        }
                    }
                    .padding(.horizontal, 30)
                }
                
                Spacer()
                
                // Logout
                Button(action: { authService.signOut() }) {
                    Text("Çıkış Yap")
                        .foregroundColor(.red)
                }
                .padding(.bottom, 20)
            }
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            if let email = authService.currentUser?.email {
                relationshipService.listenForInvitations(userEmail: email)
            }
        }
    }
    
    private func sendInvitation() {
        guard !partnerEmail.isEmpty else {
            errorMessage = "Lütfen partner e-posta adresini girin"
            showError = true
            return
        }
        
        guard let currentUser = authService.currentUser else { return }
        
        guard partnerEmail != currentUser.email else {
            errorMessage = "Kendi e-posta adresinizi giremezsiniz"
            showError = true
            return
        }
        
        isLoading = true
        Task {
            do {
                try await relationshipService.sendInvitation(
                    senderUserId: currentUser.id ?? "",
                    senderName: currentUser.name,
                    senderEmail: currentUser.email,
                    receiverEmail: partnerEmail,
                    startDate: startDate
                )
                await MainActor.run {
                    partnerEmail = ""
                    isLoading = false
                    errorMessage = "Davet gönderildi! Partnerinizin kabul etmesini bekleyin."
                    showError = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isLoading = false
                }
            }
        }
    }
}

struct InvitationCard: View {
    let invitation: PartnerInvitation
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var relationshipService: RelationshipService
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundStyle(themeManager.currentTheme.primaryColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(invitation.senderName)
                        .font(.headline)
                    Text(invitation.senderEmail)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Text("İlişki Başlangıcı: \(invitation.relationshipStartDate, formatter: DateFormatter.displayFormat)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 10) {
                Button(action: acceptInvitation) {
                    if isProcessing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Kabul Et")
                            .fontWeight(.medium)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(themeManager.currentTheme.primaryColor)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(isProcessing)
                
                Button(action: rejectInvitation) {
                    Text("Reddet")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(8)
                .disabled(isProcessing)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func acceptInvitation() {
        guard let currentUser = authService.currentUser else {
            print("❌ No current user found")
            return
        }
        
        guard let userId = currentUser.id else {
            print("❌ No user ID found")
            return
        }
        
        print("✅ Starting invitation acceptance...")
        print("   User: \(currentUser.name) (\(userId))")
        print("   Sender: \(invitation.senderName)")
        
        isProcessing = true
        Task {
            do {
                // Accept invitation and get the new relationship ID
                print("📝 Accepting invitation...")
                let relationshipId = try await relationshipService.acceptInvitation(
                    invitation,
                    receiverUserId: userId,
                    receiverName: currentUser.name
                )
                
                print("✅ Relationship created: \(relationshipId)")
                
                // Update user's relationshipId in AuthenticationService
                print("📝 Updating user relationshipId...")
                try await authService.updateRelationshipId(relationshipId)
                
                print("✅ RelationshipId updated in Firestore")
                
                // Refresh user data to update UI
                print("🔄 Refreshing user data...")
                authService.fetchUserData(userId: userId)
                
                print("🎉 Invitation accepted successfully!")
                
                await MainActor.run {
                    isProcessing = false
                }
            } catch {
                print("❌ Error accepting invitation: \(error.localizedDescription)")
                await MainActor.run {
                    errorMessage = "Davet kabul edilirken hata oluştu: \(error.localizedDescription)"
                    showError = true
                    isProcessing = false
                }
            }
        }
    }
    
    private func rejectInvitation() {
        isProcessing = true
        Task {
            do {
                try await relationshipService.rejectInvitation(invitation)
            } catch {
                print("Error rejecting invitation: \(error)")
            }
            await MainActor.run {
                isProcessing = false
            }
        }
    }
}

