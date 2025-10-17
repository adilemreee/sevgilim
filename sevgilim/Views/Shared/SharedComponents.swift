//
//  SharedComponents.swift
//  sevgilim
//
//  Optimized shared UI components for better performance

import SwiftUI

// MARK: - Gradient Background (Static)
struct AnimatedGradientBackground: View {
    let theme: AppTheme
    
    var body: some View {
        LinearGradient(
            colors: [
                theme.primaryColor.opacity(0.95),
                theme.secondaryColor.opacity(0.9),
                theme.accentColor.opacity(0.85),
                theme.primaryColor.opacity(0.95)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

