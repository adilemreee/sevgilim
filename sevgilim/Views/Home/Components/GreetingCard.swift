//
//  GreetingCard.swift
//  sevgilim
//
//  Created by refactoring HomeView
//  Dynamic greeting card based on time of day

import SwiftUI

struct GreetingCard: View {
    @EnvironmentObject var greetingService: GreetingService
    
    var greetingColor: Color {
        return greetingService.currentIcon == "sun.max.fill" ? .orange : .indigo
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: greetingService.currentIcon)
                .font(.system(size: 24))
                .foregroundStyle(
                    greetingColor.gradient
                )
                .shadow(color: greetingColor.opacity(0.5), radius: 4)
            
            Text(greetingService.currentGreeting)
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
