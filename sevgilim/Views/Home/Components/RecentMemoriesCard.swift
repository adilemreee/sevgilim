//
//  RecentMemoriesCard.swift
//  sevgilim
//
//  Created by refactoring HomeView
//  Displays recent memories preview

import SwiftUI

struct RecentMemoriesCard: View {
    let memories: [Memory]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Son Anılarımız")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "heart.text.square")
                    .foregroundColor(.white.opacity(0.7))
            }
            
            VStack(spacing: 8) {
                ForEach(memories) { memory in
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(.white.opacity(0.7))
                        Text(memory.title)
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
