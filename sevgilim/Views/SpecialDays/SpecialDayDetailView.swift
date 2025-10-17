//
//  SpecialDayDetailView.swift
//  sevgilim
//

import SwiftUI

struct SpecialDayDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var specialDayService: SpecialDayService
    @EnvironmentObject var themeManager: ThemeManager
    
    let specialDay: SpecialDay
    @State private var showingDeleteAlert = false
    @State private var isDeleting = false
    
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
        NavigationStack {
            ZStack {
                // Background
                AnimatedGradientBackground(theme: themeManager.currentTheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Icon & Title
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(cardColor.gradient)
                                    .frame(width: 120, height: 120)
                                    .shadow(color: cardColor.opacity(0.5), radius: 20)
                                
                                Image(systemName: specialDay.icon)
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                            
                            Text(specialDay.title)
                                .font(.title.bold())
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text(specialDay.category.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 20)
                        
                        // Days Until
                        if !specialDay.isPast {
                            VStack(spacing: 8) {
                                Text("\(specialDay.daysUntil)")
                                    .font(.system(size: 60, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text(specialDay.daysUntil == 0 ? "Bugün!" : "Gün Kaldı")
                                    .font(.title3)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.1), radius: 10)
                        }
                        
                        // Info Cards
                        VStack(spacing: 16) {
                            // Date
                            InfoRow(
                                icon: "calendar",
                                title: "Tarih",
                                value: specialDay.displayDate.formatted(date: .long, time: .omitted)
                            )
                            
                            // Recurring
                            if specialDay.isRecurring {
                                InfoRow(
                                    icon: "arrow.clockwise",
                                    title: "Tekrar",
                                    value: "Her yıl"
                                )
                            }
                            
                            // Notes
                            if let notes = specialDay.notes, !notes.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "note.text")
                                            .foregroundColor(themeManager.currentTheme.primaryColor)
                                        Text("Notlar")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text(notes)
                                        .font(.body)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            }
                        }
                        
                        // Delete Button
                        Button(action: { showingDeleteAlert = true }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Sil")
                            }
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .background(Color.red.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.top, 20)
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .alert("Özel Günü Sil", isPresented: $showingDeleteAlert) {
                Button("İptal", role: .cancel) {}
                Button("Sil", role: .destructive) {
                    deleteSpecialDay()
                }
            } message: {
                Text("Bu özel günü silmek istediğinizden emin misiniz?")
            }
        }
    }
    
    private func deleteSpecialDay() {
        isDeleting = true
        
        Task {
            do {
                try await specialDayService.deleteSpecialDay(specialDay)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("❌ Error deleting special day: \(error.localizedDescription)")
                isDeleting = false
            }
        }
    }
}

// MARK: - Info Row
private struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(themeManager.currentTheme.primaryColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    SpecialDayDetailView(
        specialDay: SpecialDay(
            relationshipId: "test",
            title: "İlk Buluşmamız",
            date: Date(),
            category: .firstMeet,
            icon: "eye.fill",
            color: "pink",
            notes: "Çok güzel bir gündü!",
            isRecurring: true,
            createdAt: Date(),
            createdBy: "test"
        )
    )
    .environmentObject(SpecialDayService())
    .environmentObject(ThemeManager())
}
