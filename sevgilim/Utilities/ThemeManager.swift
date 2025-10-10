//
//  ThemeManager.swift
//  sevgilim
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .romantic
    @AppStorage("selectedTheme") private var selectedThemeName: String = "romantic"
    
    init() {
        if let theme = AppTheme.allThemes.first(where: { $0.name == selectedThemeName }) {
            currentTheme = theme
        }
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        selectedThemeName = theme.name
    }
}

struct AppTheme {
    let name: String
    let displayName: String
    let primaryColor: Color
    let secondaryColor: Color
    let accentColor: Color
    let backgroundColor: Color
    let cardBackground: Color
    
    static let romantic = AppTheme(
        name: "romantic",
        displayName: "Romantik",
        primaryColor: Color(red: 255/255, green: 105/255, blue: 135/255), // Hot Pink
        secondaryColor: Color(red: 255/255, green: 182/255, blue: 193/255), // Light Pink
        accentColor: Color(red: 255/255, green: 192/255, blue: 203/255), // Pink
        backgroundColor: Color(red: 255/255, green: 250/255, blue: 250/255), // Snow
        cardBackground: .white
    )
    
    static let sunset = AppTheme(
        name: "sunset",
        displayName: "Gün Batımı",
        primaryColor: Color(red: 255/255, green: 99/255, blue: 71/255), // Tomato
        secondaryColor: Color(red: 255/255, green: 165/255, blue: 0/255), // Orange
        accentColor: Color(red: 255/255, green: 215/255, blue: 0/255), // Gold
        backgroundColor: Color(red: 255/255, green: 248/255, blue: 240/255), // Floral White
        cardBackground: .white
    )
    
    static let ocean = AppTheme(
        name: "ocean",
        displayName: "Okyanus",
        primaryColor: Color(red: 70/255, green: 130/255, blue: 180/255), // Steel Blue
        secondaryColor: Color(red: 135/255, green: 206/255, blue: 235/255), // Sky Blue
        accentColor: Color(red: 64/255, green: 224/255, blue: 208/255), // Turquoise
        backgroundColor: Color(red: 240/255, green: 248/255, blue: 255/255), // Alice Blue
        cardBackground: .white
    )
    
    static let forest = AppTheme(
        name: "forest",
        displayName: "Orman",
        primaryColor: Color(red: 34/255, green: 139/255, blue: 34/255), // Forest Green
        secondaryColor: Color(red: 144/255, green: 238/255, blue: 144/255), // Light Green
        accentColor: Color(red: 50/255, green: 205/255, blue: 50/255), // Lime Green
        backgroundColor: Color(red: 240/255, green: 255/255, blue: 240/255), // Honeydew
        cardBackground: .white
    )
    
    static let lavender = AppTheme(
        name: "lavender",
        displayName: "Lavanta",
        primaryColor: Color(red: 147/255, green: 112/255, blue: 219/255), // Medium Purple
        secondaryColor: Color(red: 216/255, green: 191/255, blue: 216/255), // Thistle
        accentColor: Color(red: 221/255, green: 160/255, blue: 221/255), // Plum
        backgroundColor: Color(red: 248/255, green: 245/255, blue: 255/255), // Lavender Blush
        cardBackground: .white
    )
    
    static let allThemes: [AppTheme] = [.romantic, .sunset, .ocean, .forest, .lavender]
}

