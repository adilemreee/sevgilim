//
//  SurpriseDetailView.swift
//  sevgilim
//

import SwiftUI
import Combine

struct SurpriseDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var surpriseService: SurpriseService
    
    let surprise: Surprise
    let partnerName: String
    let isCreatedByCurrentUser: Bool
    
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: AnyCancellable?
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
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
                    VStack(spacing: 25) {
                        // Durum Göstergesi
                        if surprise.isLocked && !isCreatedByCurrentUser {
                            // Kilitli Sürpriz
                            lockedContentView
                        } else if surprise.shouldReveal && !surprise.isOpened && !isCreatedByCurrentUser {
                            // Açılmaya Hazır ama henüz açılmamış
                            readyButNotOpenedView
                        } else {
                            // Açık İçerik veya Kendi Oluşturduğu
                            openContentView
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 30)
                }
            }
            .navigationTitle("Sürpriz Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                }
                
                if isCreatedByCurrentUser {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(role: .destructive, action: {
                            showDeleteAlert = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .alert("Sürprizi Sil", isPresented: $showDeleteAlert) {
                Button("İptal", role: .cancel) {}
                Button("Sil", role: .destructive) {
                    Task {
                        await deleteSurprise()
                    }
                }
            } message: {
                Text("Bu sürprizi silmek istediğinizden emin misiniz?")
            }
            .onAppear {
                setupTimer()
            }
            .onDisappear {
                timer?.cancel()
            }
        }
    }
    
    // MARK: - Kilitli İçerik
    
    private var lockedContentView: some View {
        VStack(spacing: 25) {
            // İkon
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "lock.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
            }
            .padding(.top, 20)
            
            // Başlık
            Text("Gizli Sürpriz")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Mesaj
            Text("Bu sürpriz henüz kilitli. İçeriği görmek için belirlenen tarihi beklemen gerekiyor.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Kimden
            VStack(spacing: 8) {
                Text("Kimden")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(partnerName)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            
            // Geri Sayım
            VStack(spacing: 15) {
                Text("Açılışa Kalan Süre")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 20) {
                    TimeUnitLarge(value: days, unit: "Gün")
                    TimeUnitLarge(value: hours, unit: "Saat")
                    TimeUnitLarge(value: minutes, unit: "Dakika")
                    TimeUnitLarge(value: seconds, unit: "Saniye")
                }
                
                Text(surprise.revealDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(surprise.revealDate, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Açılmaya Hazır ama Açılmamış
    
    private var readyButNotOpenedView: some View {
        VStack(spacing: 25) {
            // İkon
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "gift.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
            }
            .padding(.top, 20)
            
            // Başlık
            Text("Sürpriz Hazır!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Mesaj
            Text("Bu sürpriz açılmaya hazır! Sürpriz listesinden açabilirsin.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Kimden
            VStack(spacing: 8) {
                Text("Kimden")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(partnerName)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            
            // Tarih Bilgisi
            VStack(spacing: 10) {
                Text("Açılış Tarihi")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 15) {
                    Label(surprise.revealDate.formatted(date: .long, time: .omitted), systemImage: "calendar")
                    Label(surprise.revealDate.formatted(date: .omitted, time: .shortened), systemImage: "clock")
                }
                .font(.subheadline)
                .foregroundColor(.primary)
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Açık İçerik
    
    private var openContentView: some View {
        VStack(spacing: 20) {
            // Durum İkonu
            if surprise.isOpened {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                }
                .padding(.top, 10)
            }
            
            // Başlık
            Text(surprise.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            // Kimden/Kime Bilgisi
            if isCreatedByCurrentUser {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    Text("Kime: \(partnerName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left.circle.fill")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    Text("Kimden: \(partnerName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            }
            
            // Fotoğraf
            if let photoURL = surprise.photoURL, let url = URL(string: photoURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                            .clipped()
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.2), radius: 8)
                    case .failure:
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            // Mesaj
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "text.quote")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    Text("Mesaj")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Text(surprise.message)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            .padding(.top, 10)
            
            // Tarih Bilgileri
            VStack(spacing: 15) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Oluşturulma")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(surprise.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        Text("Açılış Tarihi")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(surprise.revealDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
                
                if surprise.isOpened {
                    Divider()
                    
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                        Text("Açıldı")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Time Unit Large
    
    private struct TimeUnitLarge: View {
        let value: Int
        let unit: String
        
        var body: some View {
            VStack(spacing: 6) {
                Text("\(value)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 70)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
    
    // MARK: - Computed Properties
    
    private var days: Int {
        let remaining = max(0, timeRemaining)
        return Int(remaining) / 86400
    }
    
    private var hours: Int {
        let remaining = max(0, timeRemaining)
        return (Int(remaining) % 86400) / 3600
    }
    
    private var minutes: Int {
        let remaining = max(0, timeRemaining)
        return (Int(remaining) % 3600) / 60
    }
    
    private var seconds: Int {
        let remaining = max(0, timeRemaining)
        return Int(remaining) % 60
    }
    
    // MARK: - Timer Setup
    
    private func setupTimer() {
        // İlk değeri hesapla
        timeRemaining = surprise.timeRemaining
        
        // Eğer süre dolmuş veya açılmışsa timer başlatma
        guard !surprise.isOpened && surprise.isLocked else { return }
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                let remaining = surprise.timeRemaining
                if remaining > 0 && !surprise.isOpened {
                    timeRemaining = remaining
                }
            }
    }
    
    // MARK: - Delete Surprise
    
    private func deleteSurprise() async {
        do {
            try await surpriseService.deleteSurprise(surprise)
            dismiss()
        } catch {
            print("❌ Sürpriz silinirken hata: \(error.localizedDescription)")
        }
    }
}
