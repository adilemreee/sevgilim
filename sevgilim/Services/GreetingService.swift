//
//  GreetingService.swift
//  sevgilim
//
//  Manages time-based greetings with automatic updates

import Foundation
import Combine
import SwiftUI

class GreetingService: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var currentGreeting: String = ""
    @Published private(set) var currentIcon: String = ""
    @Published private(set) var shouldShowGreeting: Bool = false
    
    // MARK: - Private Properties
    private var timer: AnyCancellable?
    private var appLifecycleSubscription: AnyCancellable?
    
    // 🔍 DEBUG MODE - Her 10 saniyede bir güncelle
    private let debugMode = false // Test için true, canlıda false yapın
    
    // MARK: - Initialization
    init() {
        updateGreeting()
        scheduleNextUpdate()
        setupAppLifecycleObserver()
        
        if debugMode {
            print("🎯 GreetingService başlatıldı - DEBUG MODE AÇIK")
            print("⏰ Şu anki saat: \(Date())")
            print("💬 Selamlama: \(currentGreeting)")
            print("🎨 İkon: \(currentIcon)")
            print("👁️ Gösterilsin mi: \(shouldShowGreeting)")
        }
    }
    
    deinit {
        timer?.cancel()
        appLifecycleSubscription?.cancel()
    }
    
    // MARK: - Private Methods
    
    private func setupAppLifecycleObserver() {
        // Uygulama ön plana geldiğinde güncelle
        appLifecycleSubscription = NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                if self?.debugMode == true {
                    print("\n📱 Uygulama ön plana geldi - güncelleniyor...")
                }
                self?.updateGreeting()
                self?.scheduleNextUpdate()
            }
    }
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        
        // Sabah 7:00 - 12:00: Günaydın
        // Gece 23:00 - Sabah 7:00: İyi Geceler
        if hour >= 7 && hour < 12 {
            currentGreeting = "Günaydın aşkımmmm"
            currentIcon = "sun.max.fill"
        } else if hour >= 23 || hour < 7 {
            currentGreeting = "İyi Geceler sevgilimmmm"
            currentIcon = "moon.stars.fill"
        } else {
            currentGreeting = ""
            currentIcon = ""
        }
        
        // Greeting gösterilmeli mi?
        shouldShowGreeting = (hour >= 23 || hour < 12)
        
        if debugMode {
            print("\n🔄 GÜNCELLENDİ!")
            print("⏰ Saat: \(Date())")
            print("🕐 Saat (hour): \(hour)")
            print("💬 Yeni selamlama: \(currentGreeting)")
            print("🎨 İkon: \(currentIcon)")
            print("👁️ Gösterilsin mi: \(shouldShowGreeting)")
        }
    }
    
    private func scheduleNextUpdate() {
        timer?.cancel()
        
        // 🔍 DEBUG MODE - Her 10 saniyede güncelle
        if debugMode {
            timer = Timer.publish(every: 10, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    print("\n⏱️ 10 saniye geçti - güncelleniyor...")
                    self?.updateGreeting()
                }
            
            print("⏱️ Bir sonraki güncelleme: 10 saniye sonra")
            return
        }
        
        // Normal mod - bir sonraki saat başında güncelle
        let now = Date()
        let calendar = Calendar.current
        
        // Bir sonraki saatin başlangıcını bul
        guard let currentHourStart = calendar.date(
            from: calendar.dateComponents([.year, .month, .day, .hour], from: now)
        ),
        let nextHour = calendar.date(byAdding: .hour, value: 1, to: currentHourStart) else {
            return
        }
        
        let timeInterval = nextHour.timeIntervalSince(now)
        
        if debugMode {
            print("⏱️ Bir sonraki güncelleme: \(nextHour) (\(Int(timeInterval/60)) dakika sonra)")
        }
        
        // Bir sonraki saat başında güncelleme yap
        timer = Timer.publish(every: timeInterval, on: .main, in: .common)
            .autoconnect()
            .first()
            .sink { [weak self] _ in
                self?.updateGreeting()
                self?.scheduleNextUpdate()
            }
    }
}
