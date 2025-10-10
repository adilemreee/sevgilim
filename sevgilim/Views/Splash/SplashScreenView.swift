//
//  SplashScreenView.swift
//  sevgilim
//

import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isAnimating = false
    @State private var heartScale: CGFloat = 0.5
    @State private var heartRotation: Double = 0
    @State private var textOpacity: Double = 0
    @State private var backgroundOpacity: Double = 0
    @State private var showContent = false
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    themeManager.currentTheme.primaryColor,
                    themeManager.currentTheme.secondaryColor,
                    themeManager.currentTheme.accentColor
                ],
                startPoint: isAnimating ? .topLeading : .bottomTrailing,
                endPoint: isAnimating ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .opacity(backgroundOpacity)
            
            VStack(spacing: 40) {
                // Animated heart logo
                ZStack {
                    // Outer glow circles
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                            .frame(width: 150 + CGFloat(index * 30), height: 150 + CGFloat(index * 30))
                            .scaleEffect(isAnimating ? 1.2 : 0.8)
                            .opacity(isAnimating ? 0 : 0.8)
                            .animation(
                                .easeOut(duration: 2)
                                .delay(Double(index) * 0.3)
                                .repeatForever(autoreverses: false),
                                value: isAnimating
                            )
                    }
                    
                    // Main heart icon
                    Image(systemName: "heart.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .pink.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(heartScale)
                        .rotationEffect(.degrees(heartRotation))
                        .shadow(color: .white.opacity(0.5), radius: 20, x: 0, y: 0)
                }
                .frame(height: 200)
                
                // App name
                VStack(spacing: 10) {
                    Text("Aşkımmmmmm")
                        .font(.system(size: 50, weight: .thin, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(textOpacity)
                    
                    Text("Aşkımmmlaaaa her annnnn")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .opacity(textOpacity)
                }
                
                // Loading indicator
                if showContent {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .transition(.opacity)
                }
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Background fade in
        withAnimation(.easeIn(duration: 0.5)) {
            backgroundOpacity = 1
        }
        
        // Background gradient animation
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            isAnimating = true
        }
        
        // Heart scale animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
            heartScale = 1.0
        }
        
        // Heart rotation animation
        withAnimation(.easeInOut(duration: 1).delay(0.5)) {
            heartRotation = 360
        }
        
        // Text fade in
        withAnimation(.easeIn(duration: 0.8).delay(0.8)) {
            textOpacity = 1
        }
        
        // Show loading indicator
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showContent = true
            }
        }
        
        // Complete splash screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                onComplete()
            }
        }
    }
}

// MARK: - Splash Screen Wrapper
struct SplashScreenWrapper<Content: View>: View {
    @State private var showSplash = true
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
                .opacity(showSplash ? 0 : 1)
            
            if showSplash {
                SplashScreenView {
                    showSplash = false
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
}

#Preview {
    SplashScreenView {
        print("Splash completed")
    }
    .environmentObject(ThemeManager())
}

