//
//  UITestHelpers.swift
//  sevgilimUITests
//
//  Created by GitHub Copilot on 17/10/2025.
//

import XCTest

/// Ortak UI test helper fonksiyonları
/// Tüm UI test dosyaları tarafından kullanılabilir

// MARK: - XCUIElement Extension

extension XCUIElement {
    /// TextField'daki mevcut text'i temizler
    /// - Note: Backspace tuşunu character sayısı kadar basar
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}

// MARK: - Thread Sleep Helper

extension Thread {
    /// UI testlerinde kullanım kolaylığı için sleep wrapper
    /// - Parameter seconds: Bekleme süresi (saniye)
    static func sleep(seconds: Double) {
        Thread.sleep(forTimeInterval: seconds)
    }
}
