//
//  SurpriseCardView.swift
//  sevgilim
//

import SwiftUI
import Combine

struct SurpriseCardView: View {
    let surprise: Surprise
    let isCreatedByCurrentUser: Bool
    let partnerName: String
    let onOpen: () -> Void
    
    @State private var timeRemaining: TimeInterval = 0
    @State private var showContent = false
    @State private var showConfetti = false
    @State private var giftRotation: Double = 0
    @State private var giftScale: CGFloat = 1.0
    @State private var contentOpacity: Double = 0
    @State private var timer: AnyCancellable?
    
    var body: some View {
        ZStack {
            if surprise.isLocked && !isCreatedByCurrentUser {
                // Kilitli görünüm - Fotodaki gibi kompakt
                lockedViewCompact
            } else if surprise.shouldReveal && !surprise.isOpened && !isCreatedByCurrentUser {
                // Açılmaya hazır
                readyToOpenView
            } else {
                // Açık içerik veya kendi hazırladığı sürpriz
                contentView
            }
        }
        .onAppear {
            setupTimer()
            checkAndReveal()
        }
        .onDisappear {
            timer?.cancel()
        }
        .confetti(isActive: showConfetti)
    }
    
    // MARK: - Locked View Compact (Fotodaki gibi)
    
    private var lockedViewCompact: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.body)
                    Text(surprise.title.isEmpty ? "Gizli Sürpriz" : surprise.title)
                        .font(.headline)
                        .lineLimit(1)
                }
                .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.horizontal, 20)
            
            // Message
            VStack(spacing: 8) {
                Text("İçeriği görmek için zamanı bekle!")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 12)
                
                Text("Açılışa Kalan Süre")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 2)
                
                // Geri sayım
                HStack(spacing: 12) {
                    TimeUnitCompact(value: days, unit: "Gün")
                    Text(":")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.title3)
                    TimeUnitCompact(value: hours, unit: "Saat")
                    Text(":")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.title3)
                    TimeUnitCompact(value: minutes, unit: "Dk")
                    Text(":")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.title3)
                    TimeUnitCompact(value: seconds, unit: "Sn")
                }
                .padding(.vertical, 12)
            }
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color(red: 0.3, green: 0.3, blue: 0.35), Color(red: 0.25, green: 0.25, blue: 0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Time Unit Compact
    
    private struct TimeUnitCompact: View {
        let value: Int
        let unit: String
        
        var body: some View {
            VStack(spacing: 2) {
                Text("\(value)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()
                
                Text(unit)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(width: 45)
        }
    }
    
    // MARK: - Ready to Open View
    
    private var readyToOpenView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "gift.fill")
                        .font(.body)
                    Text(surprise.title)
                        .font(.headline)
                        .lineLimit(1)
                }
                .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.horizontal, 20)
            
            // Content
            VStack(spacing: 12) {
                Text("🎉 Sürpriz Hazır")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.top, 16)
                
                Text("Dokun ve sürprizi aç")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                
                Button(action: {
                    openSurprise()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "gift")
                        Text("Sürprizi Aç")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.25))
                    .cornerRadius(20)
                }
                .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.8), Color.pink.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        .onAppear {
            startPulseAnimation()
        }
    }
    
    // MARK: - Content View
    
    private var contentView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    if isCreatedByCurrentUser {
                        Text("Kime:")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text(partnerName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    } else {
                        Image(systemName: "gift.fill")
                            .font(.body)
                    }
                    if !isCreatedByCurrentUser {
                        Text(surprise.title)
                            .font(.headline)
                            .lineLimit(1)
                    }
                }
                .foregroundColor(.white)
                
                Spacer()
                
                if isCreatedByCurrentUser {
                    // Kilit durumu göstergesi
                    HStack(spacing: 4) {
                        if surprise.isLocked {
                            // Henüz kilitli
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(.orange.opacity(0.9))
                        } else if surprise.isOpened {
                            // Açıldı
                            Image(systemName: "lock.open.fill")
                                .font(.caption)
                                .foregroundColor(.green.opacity(0.9))
                        } else {
                            // Açılmaya hazır ama henüz açılmamış
                            Image(systemName: "lock.open.fill")
                                .font(.caption)
                                .foregroundColor(.yellow.opacity(0.9))
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            if isCreatedByCurrentUser {
                // Hazırladığın sürpriz için başlık göster
                HStack {
                    Text(surprise.title)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.horizontal, 20)
            
            // Content area
            VStack(alignment: .leading, spacing: 10) {
                if !isCreatedByCurrentUser && !surprise.isOpened {
                    // Henüz açılmamış - mesajı gösterme
                    EmptyView()
                } else {
                    // Mesaj
                    if !surprise.message.isEmpty {
                        Text(surprise.message)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(isCreatedByCurrentUser ? 2 : nil)
                    }
                    
                    // Fotoğraf
                    if let photoURL = surprise.photoURL, !isCreatedByCurrentUser {
                        AsyncImage(url: URL(string: photoURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 180)
                                    .cornerRadius(12)
                                    .clipped()
                            case .failure(_):
                                placeholderImage
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 180)
                            @unknown default:
                                placeholderImage
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                
                // Tarih bilgisi - sadece açılmamışsa göster
                if !surprise.isOpened {
                    Text(isCreatedByCurrentUser ? "Açılışa Kalan Süre" : "Açılışa Kalan Süre")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 8)
                }
                
                // Geri sayım veya tarih
                if !surprise.isOpened && (isCreatedByCurrentUser || surprise.isLocked) {
                    HStack(spacing: 12) {
                        TimeUnitCompact(value: days, unit: "Gün")
                        Text(":")
                            .foregroundColor(.white.opacity(0.5))
                            .font(.title3)
                        TimeUnitCompact(value: hours, unit: "Saat")
                        Text(":")
                            .foregroundColor(.white.opacity(0.5))
                            .font(.title3)
                        TimeUnitCompact(value: minutes, unit: "Dk")
                        Text(":")
                            .foregroundColor(.white.opacity(0.5))
                            .font(.title3)
                        TimeUnitCompact(value: seconds, unit: "Sn")
                    }
                } else if surprise.isOpened {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                        Text("Açıldı: \(surprise.openedAt?.formatted(date: .abbreviated, time: .shortened) ?? "")")
                            .font(.caption)
                    }
                    .foregroundColor(.green.opacity(0.9))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: isCreatedByCurrentUser 
                    ? [Color(red: 0.3, green: 0.3, blue: 0.35), Color(red: 0.25, green: 0.25, blue: 0.3)]
                    : [Color.pink.opacity(0.8), Color.purple.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        .opacity(showContent ? 1 : 0)
        .scaleEffect(showContent ? 1 : 0.8)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showContent = true
                contentOpacity = 1
            }
        }
    }
    
    private var placeholderImage: some View {
        Rectangle()
            .fill(Color.white.opacity(0.2))
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .cornerRadius(12)
            .overlay(
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundColor(.white.opacity(0.5))
            )
    }
    
    // MARK: - Computed Properties
    
    private var days: Int {
        return max(0, Int(timeRemaining) / 86400)
    }
    
    private var hours: Int {
        return max(0, (Int(timeRemaining) % 86400) / 3600)
    }
    
    private var minutes: Int {
        return max(0, (Int(timeRemaining) % 3600) / 60)
    }
    
    private var seconds: Int {
        return max(0, Int(timeRemaining) % 60)
    }
    
    // MARK: - Functions
    
    private func setupTimer() {
        // Eğer sürpriz açıldıysa timer başlatma
        if surprise.isOpened {
            timeRemaining = 0
            return
        }
        
        timeRemaining = max(0, surprise.timeRemaining)
        
        // Timer'ı sadece açılmamış sürprizler için başlat
        if !surprise.isOpened {
            timer = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [self] _ in
                    if timeRemaining > 0 && !surprise.isOpened {
                        timeRemaining -= 1
                    } else {
                        timer?.cancel()
                        if !surprise.isOpened {
                            checkAndReveal()
                        }
                    }
                }
        }
    }
    
    private func checkAndReveal() {
        if surprise.shouldReveal && !surprise.isOpened && !isCreatedByCurrentUser {
            // Otomatik açılış animasyonu göster
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Kullanıcı manuel açsın
            }
        }
    }
    
    private func openSurprise() {
        // Animasyonlar
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            giftScale = 1.5
            giftRotation = 360
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showConfetti = true
            
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
            
            // Konfeti bitince içeriği fade-in yap
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeIn(duration: 0.8)) {
                    contentOpacity = 1
                }
            }
            
            // Backend'e açıldığını bildir
            onOpen()
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(
            .easeInOut(duration: 1.0)
            .repeatForever(autoreverses: true)
        ) {
            giftScale = 1.2
        }
        
        withAnimation(
            .linear(duration: 2.0)
            .repeatForever(autoreverses: false)
        ) {
            giftRotation = 10
        }
    }
}
