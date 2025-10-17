//
//  UpcomingSpecialDayWidget.swift
//  sevgilim
//
//  Created by refactoring HomeView
//  Widget for upcoming special day with countdown

import SwiftUI

struct UpcomingSpecialDayWidget: View {
    let specialDay: SpecialDay
    let onTap: () -> Void
    
    @State private var pulseAnimation = false
    
    private var cardColor: Color {
        switch specialDay.color {
        case "red": return .red
        case "orange": return .orange
        case "pink": return .pink
        case "purple": return .purple
        case "blue": return .blue
        case "indigo": return .indigo
        case "cyan": return .cyan
        case "yellow": return .yellow
        case "mint": return .mint
        default: return .gray
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Header
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: specialDay.icon)
                            .font(.body)
                            .foregroundColor(cardColor)
                        Text(specialDay.isToday ? "Bugün Özel Gün!" : "Yaklaşan Özel Gün")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.horizontal, 20)
                
                // Content
                HStack(spacing: 16) {
                    // Icon with days
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(cardColor.gradient)
                                .frame(width: 70, height: 70)
                                .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                            
                            Image(systemName: specialDay.icon)
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        
                        if !specialDay.isToday {
                            VStack(spacing: 2) {
                                Text("\(specialDay.daysUntil)")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                                Text("gün")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        } else {
                            Text("🎉")
                                .font(.title2)
                        }
                    }
                    
                    // Info
                    VStack(alignment: .leading, spacing: 6) {
                        Text(specialDay.title)
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        Text(specialDay.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption2)
                            Text(specialDay.displayDate, style: .date)
                                .font(.caption)
                            
                            if specialDay.isRecurring {
                                Image(systemName: "arrow.clockwise")
                                    .font(.caption2)
                            }
                        }
                        .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [cardColor.opacity(0.3), cardColor.opacity(0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: cardColor.opacity(0.3), radius: 15, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                pulseAnimation = true
            }
        }
    }
}
