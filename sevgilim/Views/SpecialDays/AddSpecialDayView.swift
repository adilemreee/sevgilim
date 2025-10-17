//
//  AddSpecialDayView.swift
//  sevgilim
//

import SwiftUI

struct AddSpecialDayView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var specialDayService: SpecialDayService
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var title = ""
    @State private var selectedDate = Date()
    @State private var selectedCategory: SpecialDayCategory = .other
    @State private var notes = ""
    @State private var isRecurring = false
    @State private var isSaving = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background - Same as SpecialDaysView
                LinearGradient(
                    colors: [
                        themeManager.currentTheme.primaryColor.opacity(0.3),
                        themeManager.currentTheme.secondaryColor.opacity(0.2)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack(spacing: 12) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 24))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.pink, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Yeni Özel Gün")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Text("Önemli bir gün ekleyin")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // Form Fields
                        VStack(spacing: 16) {
                            // Başlık
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Başlık", systemImage: "text.cursor")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                TextField("Örn: aşkımla pizza date skdmfksmdfk", text: $title)
                                    .padding(12)
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                            }
                            
                            // Kategori
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Kategori", systemImage: "tag")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                Picker("Kategori", selection: $selectedCategory) {
                                    ForEach(SpecialDayCategory.allCases, id: \.self) { category in
                                        HStack {
                                            Image(systemName: category.icon)
                                            Text(category.rawValue)
                                        }
                                        .tag(category)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding(12)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                                .accentColor(themeManager.currentTheme.primaryColor)
                            }
                            
                            // Tarih
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Tarih", systemImage: "calendar")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .accentColor(themeManager.currentTheme.primaryColor)
                                    .environment(\.locale, Locale(identifier: "tr_TR"))
                                    .padding(12)
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                            }
                            
                            // Her yıl tekrarla
                            Toggle(isOn: $isRecurring) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.clockwise")
                                        .foregroundColor(themeManager.currentTheme.primaryColor)
                                    Text("Her yıl tekrarla")
                                }
                            }
                            .padding(12)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                            
                            // Notlar
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Notlar (Opsiyonel)", systemImage: "note.text")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                TextEditor(text: $notes)
                                    .frame(height: 100)
                                    .scrollContentBackground(.hidden)
                                    .padding(12)
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Kaydet Butonu
                        Button(action: saveSpecialDay) {
                            HStack {
                                if isSaving {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Kaydet")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 14)
                            .background(themeManager.currentTheme.primaryColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(title.isEmpty || isSaving)
                        .opacity(title.isEmpty ? 0.5 : 1.0)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Geri")
                        }
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func saveSpecialDay() {
        guard !title.isEmpty,
              let userId = authService.currentUser?.id,
              let relationshipId = authService.currentUser?.relationshipId else {
            return
        }
        
        isSaving = true
        
        Task {
            do {
                try await specialDayService.addSpecialDay(
                    relationshipId: relationshipId,
                    userId: userId,
                    title: title,
                    date: selectedDate,
                    category: selectedCategory,
                    notes: notes.isEmpty ? nil : notes,
                    isRecurring: isRecurring
                )
                
                // Small delay to ensure Firestore listener receives the update
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("❌ Error saving special day: \(error.localizedDescription)")
                await MainActor.run {
                    isSaving = false
                }
            }
        }
    }
}

// MARK: - Modern Text Field Style
struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .foregroundColor(.white)
    }
}

#Preview {
    AddSpecialDayView()
        .environmentObject(SpecialDayService())
        .environmentObject(AuthenticationService())
        .environmentObject(ThemeManager())
}
