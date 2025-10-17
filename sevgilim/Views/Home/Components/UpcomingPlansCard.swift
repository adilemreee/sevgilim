//
//  UpcomingPlansCard.swift
//  sevgilim
//
//  Created by refactoring HomeView
//  Displays upcoming plans preview

import SwiftUI

struct UpcomingPlansCard: View {
    let plans: [Plan]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Yaklaşan Planlarımız")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "calendar")
                    .foregroundColor(.white.opacity(0.7))
            }
            
            VStack(spacing: 8) {
                ForEach(plans) { plan in
                    HStack {
                        Image(systemName: "circle")
                            .foregroundColor(.white.opacity(0.7))
                        Text(plan.title)
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .lineLimit(1)
                        Spacer()
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
