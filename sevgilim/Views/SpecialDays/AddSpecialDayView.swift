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
        NavigationStack {
            ZStack {
                // Background
                AnimatedGradientBackground(theme: themeManager.currentTheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Başlık
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Başlık")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            TextField("Örn: İlk Buluşmamız", text: $title)
                                .textFieldStyle(ModernTextFieldStyle())
                        }
                        
                        // Kategori
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Kategori")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            
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
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .accentColor(themeManager.currentTheme.primaryColor)
                        }
                        
                        // Tarih
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tarih")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .accentColor(themeManager.currentTheme.primaryColor)
                                .padding()
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        }
                        
                        // Her yıl tekrarla
                        Toggle(isOn: $isRecurring) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                                Text("Her yıl tekrarla")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        
                        // Notlar
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notlar (Opsiyonel)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            TextEditor(text: $notes)
                                .frame(height: 100)
                                .scrollContentBackground(.hidden)
                                .padding(12)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                .foregroundColor(.white)
                        }
                        
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
                            .padding(.vertical, 16)
                            .background(themeManager.currentTheme.primaryColor)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(title.isEmpty || isSaving)
                        .opacity(title.isEmpty ? 0.5 : 1.0)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Yeni Özel Gün")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
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
