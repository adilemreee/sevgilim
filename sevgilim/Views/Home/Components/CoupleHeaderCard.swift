//
//  CoupleHeaderCard.swift
//  sevgilim
//
//  Created by refactoring HomeView
//  Modern couple header with animated hearts

import SwiftUI

struct CoupleHeaderCard: View {
    let user1Name: String
    let user2Name: String
    @Binding var animateHearts: Bool
    @State private var tapAnimations: [TapHeartAnimation] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sevgilimmm")
                .font(.system(size: 45, weight: .thin, design: .rounded))
                .foregroundColor(.white)
            
            HStack(spacing: 25) {
                Text(user1Name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                ZStack {
                    // Otomatik kalp animasyonu
                    Image(systemName: "heart.fill")
                        .font(.title)
                        .foregroundColor(.red)
                        .scaleEffect(animateHearts ? 1.15 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateHearts)
                    
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                            .foregroundColor(.pink.opacity(0.7))
                            .offset(
                                x: [0, -25, 25][index],
                                y: animateHearts ? -30 : 0
                            )
                            .opacity(animateHearts ? 0 : 1)
                            .animation(
                                .easeOut(duration: 2)
                                .delay(Double(index) * 0.3)
                                .repeatForever(autoreverses: false),
                                value: animateHearts
                            )
                    }
                    
                    // Tıklama animasyonları
                    ForEach(tapAnimations) { animation in
                        TapHeartView(animation: animation)
                    }
                }
                .onTapGesture {
                    createTapAnimation()
                }
                
                Text(user2Name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }
    
    private func createTapAnimation() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Her tıklamada 8 kalp oluştur
        let heartCount = 8
        for i in 0..<heartCount {
            let angle = (Double(i) / Double(heartCount)) * 360.0
            let animation = TapHeartAnimation(
                id: UUID(),
                angle: angle,
                color: [Color.red, Color.pink, Color.purple, Color.orange].randomElement() ?? .red
            )
            tapAnimations.append(animation)
        }
        
        // 1.5 saniye sonra animasyonları temizle
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            tapAnimations.removeAll()
        }
    }
}

// MARK: - Supporting Types

struct TapHeartAnimation: Identifiable {
    let id: UUID
    let angle: Double
    let color: Color
}

struct TapHeartView: View {
    let animation: TapHeartAnimation
    @State private var isAnimating = false
    
    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 20))
            .foregroundColor(animation.color)
            .offset(
                x: isAnimating ? cos(animation.angle * .pi / 180) * 80 : 0,
                y: isAnimating ? sin(animation.angle * .pi / 180) * 80 : 0
            )
            .scaleEffect(isAnimating ? 1.5 : 0.5)
            .opacity(isAnimating ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: 1.2)) {
                    isAnimating = true
                }
            }
    }
}
