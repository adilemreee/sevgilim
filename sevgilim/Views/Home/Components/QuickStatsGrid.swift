//
//  QuickStatsGrid.swift
//  sevgilim
//
//  Created by refactoring HomeView
//  Grid of quick statistics

import SwiftUI

struct QuickStatsGrid: View {
    let photosCount: Int
    let memoriesCount: Int
    let notesCount: Int
    let plansCount: Int
    let theme: AppTheme
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 15) {
            StatCardModern(
                title: "Fotoğraflar",
                value: "\(photosCount)",
                icon: "photo.stack.fill",
                color: .blue
            )
            
            StatCardModern(
                title: "Anılar",
                value: "\(memoriesCount)",
                icon: "heart.text.square.fill",
                color: .pink
            )
            
            StatCardModern(
                title: "Notlar",
                value: "\(notesCount)",
                icon: "note.text",
                color: .orange
            )
            
            StatCardModern(
                title: "Planlar",
                value: "\(plansCount)",
                icon: "list.star",
                color: .purple
            )
        }
    }
}

// MARK: - Stat Card

struct StatCardModern: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @State private var animateCard = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .scaleEffect(animateCard ? 1.02 : 1.0)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) {
                animateCard = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    animateCard = false
                }
            }
        }
    }
}
