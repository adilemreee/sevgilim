//
//  RegisterView.swift
//  sevgilim
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
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
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 10) {
                            Image(systemName: "person.crop.circle.fill.badge.plus")
                                .font(.system(size: 60))
                                .foregroundStyle(themeManager.currentTheme.primaryColor)
                            
                            Text("Hesap Oluştur")
                                .font(.title.bold())
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 20)
                        
                        // Form
                        VStack(spacing: 20) {
                            TextField("İsminiz", text: $name)
                                .textFieldStyle(CustomTextFieldStyle())
                            
                            TextField("E-posta", text: $email)
                                .textFieldStyle(CustomTextFieldStyle())
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                            
                            SecureField("Şifre", text: $password)
                                .textFieldStyle(CustomTextFieldStyle())
                            
                            SecureField("Şifre Tekrar", text: $confirmPassword)
                                .textFieldStyle(CustomTextFieldStyle())
                            
                            Button(action: register) {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Kayıt Ol")
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
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
            .alert("Hata", isPresented: $showError) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func register() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Lütfen tüm alanları doldurun"
            showError = true
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Şifreler eşleşmiyor"
            showError = true
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Şifre en az 6 karakter olmalıdır"
            showError = true
            return
        }
        
        isLoading = true
        Task {
            do {
                try await authService.signUp(email: email, password: password, name: name)
                await MainActor.run {
                    dismiss()
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

