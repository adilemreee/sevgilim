//
//  ForgotPasswordView.swift
//  sevgilim
//

import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("E-posta adresini girersen sana sıfırlama bağlantısı göndereceğiz.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                TextField("E-posta", text: $email)
                    .textFieldStyle(CustomTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                
                Button(action: sendResetEmail) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Bağlantı Gönder")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(isLoading)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Şifremi Unuttum")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
            .alert("Bilgi", isPresented: $showAlert) {
                Button("Tamam", role: .cancel) {
                    if alertMessage.contains("gönderildi") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func sendResetEmail() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            alertMessage = "Lütfen e-posta adresini gir."
            showAlert = true
            return
        }
        
        isLoading = true
        Task {
            do {
                try await authService.sendPasswordReset(email: trimmedEmail)
                await MainActor.run {
                    alertMessage = "Sıfırlama bağlantısı e-postana gönderildi."
                    showAlert = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    alertMessage = authService.errorMessage ?? "Bir hata oluştu. Lütfen tekrar dene."
                    showAlert = true
                    isLoading = false
                }
            }
        }
    }
}
