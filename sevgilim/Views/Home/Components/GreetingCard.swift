//
//  GreetingCard.swift
//  sevgilim
//
//  Created by refactoring HomeView
//  Dynamic greeting card based on time of day

import SwiftUI

struct GreetingCard: View {
    let currentDate: Date
    
    var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: currentDate)
        // Sabah 7:00 - 12:00: Günaydın
        // Gece 23:00 - Sabah 7:00: İyi Geceler
        if hour >= 7 && hour < 12 {
            return "Günaydın aşkımmmm"
        } else {
            return "İyi Geceler sevgilimmmm"
        }
    }
    
    var greetingIcon: String {
        let hour = Calendar.current.component(.hour, from: currentDate)
        if hour >= 7 && hour < 12 {
            return "sun.max.fill"
        } else {
            return "moon.stars.fill"
        }
    }
    
    var greetingColor: Color {
        let hour = Calendar.current.component(.hour, from: currentDate)
        if hour >= 7 && hour < 12 {
            return .orange
        } else {
            return .indigo
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: greetingIcon)
                .font(.system(size: 24))
                .foregroundStyle(
                    greetingColor.gradient
                )
                .shadow(color: greetingColor.opacity(0.5), radius: 4)
            
            Text(greetingMessage)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [
                    greetingColor.opacity(0.3),
                    greetingColor.opacity(0.15)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: greetingColor.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}
