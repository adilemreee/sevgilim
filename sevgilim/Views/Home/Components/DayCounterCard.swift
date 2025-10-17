//
//  DayCounterCard.swift
//  sevgilim
//
//  Created by refactoring HomeView
//  Displays days together counter

import SwiftUI

struct DayCounterCard: View {
    let startDate: Date
    let currentDate: Date
    let theme: AppTheme
    
    var daysSince: Int {
        startDate.daysBetween(currentDate)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Birlikte Geçirdiğimiz Zaman")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Text("\(daysSince)")
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("GÜN")
                .font(.callout.bold())
                .foregroundColor(.white.opacity(0.8))
            
            Text(currentDate.formattedDifference(from: startDate))
                .font(.callout)
                .foregroundColor(.white.opacity(0.7))
            
            Text("Başlangıç: \(startDate, formatter: DateFormatter.displayFormat)")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
    }
}
