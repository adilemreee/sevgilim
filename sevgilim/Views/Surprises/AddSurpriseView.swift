//
//  AddSurpriseView.swift
//  sevgilim
//

import SwiftUI
import PhotosUI

struct AddSurpriseView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var surpriseService: SurpriseService
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var relationshipService: RelationshipService
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var title = ""
    @State private var message = ""
    @State private var revealDate = Date().addingTimeInterval(3600) // Default 1 saat sonra
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background - Temaya uyumlu
                LinearGradient(
                    colors: [
                        themeManager.currentTheme.primaryColor.opacity(0.15),
                        themeManager.currentTheme.secondaryColor.opacity(0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Form Content
                        VStack(spacing: 16) {
                            // Başlık
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Başlık", systemImage: "text.quote")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                                
                                TextField("Sürpriz başlığı", text: $title)
                                    .textFieldStyle(.plain)
                                    .padding(12)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                            }
                            
                            // Mesaj
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Mesaj", systemImage: "text.alignleft")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                                
                                ZStack(alignment: .topLeading) {
                                    if message.isEmpty {
                                        Text("Sevdiğin kişiye ne söylemek istersin?")
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                    }
                                    
                                    TextEditor(text: $message)
                                        .frame(height: 120)
                                        .padding(8)
                                        .scrollContentBackground(.hidden)
                                        .background(Color(.systemBackground))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color(.systemGray4), lineWidth: 1)
                                        )
                                }
                            }
                            
                            // Fotoğraf
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Fotoğraf (İsteğe Bağlı)", systemImage: "photo")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                                
                                if let image = selectedImage {
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 200)
                                            .frame(maxWidth: .infinity)
                                            .cornerRadius(10)
                                            .clipped()
                                        
                                        Button(action: {
                                            withAnimation {
                                                selectedImage = nil
                                            }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(.white)
                                                .background(Circle().fill(Color.black.opacity(0.6)))
                                        }
                                        .padding(8)
                                    }
                                } else {
                                    Button(action: {
                                        showImagePicker = true
                                    }) {
                                        VStack(spacing: 10) {
                                            Image(systemName: "photo.on.rectangle.angled")
                                                .font(.system(size: 32))
                                            Text("Fotoğraf Ekle")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                        }
                                        .foregroundColor(themeManager.currentTheme.primaryColor)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 140)
                                        .background(Color(.systemBackground))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .strokeBorder(
                                                    style: StrokeStyle(lineWidth: 2, dash: [8])
                                                )
                                                .foregroundColor(Color(.systemGray4))
                                        )
                                    }
                                }
                            }
                            
                            // Tarih ve Saat
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Açılış Tarihi ve Saati", systemImage: "calendar.badge.clock")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                                
                                DatePicker(
                                    "",
                                    selection: $revealDate,
                                    in: Date()...,
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .padding(12)
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                                .accentColor(themeManager.currentTheme.primaryColor)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "info.circle")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("Sürpriz bu tarihte açılacak")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Kaydet Butonu
                        Button(action: saveSurprise) {
                            HStack(spacing: 8) {
                                if isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "gift.fill")
                                    Text("Sürprizi Kaydet")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [themeManager.currentTheme.primaryColor, themeManager.currentTheme.secondaryColor],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isSaving || !isFormValid)
                        .opacity(isFormValid ? 1 : 0.5)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Yeni Sürpriz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .alert("Hata", isPresented: $showError) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               revealDate > Date()
    }
    
    // MARK: - Functions
    
    private func saveSurprise() {
        guard let currentUser = authService.currentUser,
              let currentUserId = currentUser.id,
              let relationship = relationshipService.currentRelationship else {
            errorMessage = "Kullanıcı bilgileri alınamadı"
            showError = true
            return
        }
        
        // Partner ID'yi bul
        let partnerId = relationship.user1Id == currentUserId ? relationship.user2Id : relationship.user1Id
        
        isSaving = true
        
        Task {
            do {
                try await surpriseService.addSurprise(
                    relationshipId: relationship.id ?? "",
                    createdBy: currentUserId,
                    createdFor: partnerId,
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    message: message.trimmingCharacters(in: .whitespacesAndNewlines),
                    revealDate: revealDate,
                    image: selectedImage
                )
                
                await MainActor.run {
                    isSaving = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = "Sürpriz kaydedilemedi: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}
