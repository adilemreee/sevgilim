//
//  SharedComponents.swift
//  sevgilim
//
//  Optimized shared UI components for better performance

import SwiftUI

// MARK: - Animated Gradient Background (Optimized)
struct AnimatedGradientBackground: View {
    let theme: AppTheme
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                theme.primaryColor.opacity(0.75),
                theme.secondaryColor.opacity(0.68),
                theme.accentColor.opacity(0.60),
                theme.primaryColor.opacity(0.75)
            ],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .task {
            // Use task for better lifecycle management
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
        .drawingGroup() // Optimize rendering performance
    }
}

