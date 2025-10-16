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
                theme.primaryColor.opacity(0.75),
                theme.secondaryColor.opacity(0.68),
                theme.accentColor.opacity(0.60),
                theme.primaryColor.opacity(0.75)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

