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
    @State private var pulseScale: CGFloat = 1.0
    @State private var shimmerOffset: CGFloat = -300
    @State private var floatingHearts: [FloatingHeart] = []
    @State private var particleOpacity: Double = 0
    
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
            
            // Floating particles background
            GeometryReader { geometry in
                ZStack {
                    ForEach(floatingHearts) { heart in
                        Image(systemName: "heart.fill")
                            .font(.system(size: heart.size))
                            .foregroundColor(.white.opacity(heart.opacity))
                            .position(x: heart.x, y: heart.y)
                            .rotationEffect(.degrees(heart.rotation))
                            .blur(radius: 2)
                    }
                }
                .opacity(particleOpacity)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Animated heart logo
                ZStack {
                    // Outer glow circles with pulse
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.4), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                            .frame(width: 150 + CGFloat(index * 30), height: 150 + CGFloat(index * 30))
                            .scaleEffect(isAnimating ? 1.3 : 0.8)
                            .opacity(isAnimating ? 0 : 0.9)
                            .animation(
                                .easeOut(duration: 2)
                                .delay(Double(index) * 0.3)
                                .repeatForever(autoreverses: false),
                                value: isAnimating
                            )
                    }
                    
                    // Rotating ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.6), .white.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [10, 10])
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(heartRotation))
                    
                    // Inner glow circle with pulse
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 70
                            )
                        )
                        .frame(width: 140, height: 140)
                        .scaleEffect(pulseScale)
                    
                    // Main heart icon with shimmer
                    ZStack {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .pink.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .white.opacity(0.8), radius: 20, x: 0, y: 0)
                            .shadow(color: themeManager.currentTheme.primaryColor.opacity(0.5), radius: 30, x: 0, y: 0)
                        
                        // Shimmer overlay
                        Image(systemName: "heart.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        .white.opacity(0.8),
                                        .clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .mask(
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 80))
                            )
                            .offset(x: shimmerOffset)
                    }
                    .scaleEffect(heartScale)
                    
                    // Sparkles around heart
                    ForEach(0..<8, id: \.self) { index in
                        Image(systemName: "sparkle")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                            .offset(
                                x: cos(Double(index) * .pi / 4) * 80,
                                y: sin(Double(index) * .pi / 4) * 80
                            )
                            .scaleEffect(isAnimating ? 1.5 : 0.5)
                            .opacity(isAnimating ? 0 : 1)
                            .animation(
                                .easeInOut(duration: 1.5)
                                .delay(Double(index) * 0.1)
                                .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                    }
                }
                .frame(height: 200)
                
                // App name with enhanced effects
                VStack(spacing: 10) {
                    ZStack {
                        // Glow effect behind text
                        Text("Aşkımmmmmm")
                            .font(.system(size: 50, weight: .thin, design: .rounded))
                            .foregroundColor(.white)
                            .blur(radius: 10)
                            .opacity(textOpacity * 0.5)
                        
                        // Main text
                        Text("Aşkımmmmmm")
                            .font(.system(size: 50, weight: .thin, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.9)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .white.opacity(0.5), radius: 5, x: 0, y: 2)
                            .opacity(textOpacity)
                    }
                    
                    Text("Aşkımmmlaaaa her annnnn")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        .opacity(textOpacity)
                }
            }
        }
        .onAppear {
            startAnimations()
            generateFloatingHearts()
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
        
        // Heart scale animation with bounce
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
            heartScale = 1.0
        }
        
        // Heart rotation animation - continuous
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            heartRotation = 360
        }
        
        // Pulse animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.5)) {
            pulseScale = 1.3
        }
        
        // Shimmer animation
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false).delay(0.8)) {
            shimmerOffset = 300
        }
        
        // Particle fade in
        withAnimation(.easeIn(duration: 1).delay(0.5)) {
            particleOpacity = 1
        }
        
        // Text fade in
        withAnimation(.easeIn(duration: 0.8).delay(0.8)) {
            textOpacity = 1
        }
        
        // Complete splash screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                onComplete()
            }
        }
    }
    
    private func generateFloatingHearts() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        for _ in 0..<15 {
            let heart = FloatingHeart(
                x: CGFloat.random(in: 0...screenWidth),
                y: CGFloat.random(in: 0...screenHeight),
                size: CGFloat.random(in: 15...35),
                opacity: Double.random(in: 0.2...0.5),
                rotation: Double.random(in: -45...45)
            )
            floatingHearts.append(heart)
            
            // Animate floating
            withAnimation(
                .linear(duration: Double.random(in: 3...6))
                .repeatForever(autoreverses: true)
                .delay(Double.random(in: 0...2))
            ) {
                if let index = floatingHearts.firstIndex(where: { $0.id == heart.id }) {
                    floatingHearts[index].y += CGFloat.random(in: -100...100)
                    floatingHearts[index].x += CGFloat.random(in: -50...50)
                    floatingHearts[index].rotation += Double.random(in: -180...180)
                }
            }
        }
    }
}

// MARK: - Floating Heart Model
struct FloatingHeart: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var rotation: Double
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
            if !showSplash {
                content
                    .transition(.opacity)
            }
            
            if showSplash {
                SplashScreenView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                    }
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

