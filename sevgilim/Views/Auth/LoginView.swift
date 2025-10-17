//
//  LoginView.swift
//  sevgilim
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var themeManager: ThemeManager
    @State private var email = ""
    @State private var password = ""
    @State private var showingRegister = false
    @State private var isLoading = false
    @State private var showError = false
    
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
                
                // Logo/Title
                VStack(spacing: 10) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(themeManager.currentTheme.primaryColor)
                    
                    Text("Sevgilim")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    
                    Text("Aşkımla bizim uygulmamıza giriş")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 40)
                
                // Login Form
                VStack(spacing: 20) {
                    TextField("E-posta", text: $email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Şifre", text: $password)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    Button(action: login) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Giriş Yap")
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
                
                // Register Link
                Button(action: { showingRegister = true }) {
                    Text("Hesabınız yok mu? **Kayıt Olun**")
                        .foregroundColor(.primary)
                }
                .padding(.top, 10)
                
                Spacer()
            }
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(authService.errorMessage ?? "Bilinmeyen bir hata oluştu")
        }
        .sheet(isPresented: $showingRegister) {
            RegisterView()
        }
    }
    
    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            authService.errorMessage = "Lütfen tüm alanları doldurun"
            showError = true
            return
        }
        
        isLoading = true
        Task {
            do {
                try await authService.signIn(email: email, password: password)
            } catch {
                await MainActor.run {
                    showError = true
                    isLoading = false
                }
            }
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

