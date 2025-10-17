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
    
    static let midnight = AppTheme(
        name: "midnight",
        displayName: "Gece Yarısı",
        primaryColor: Color(red: 25/255, green: 25/255, blue: 112/255), // Midnight Blue
        secondaryColor: Color(red: 72/255, green: 61/255, blue: 139/255), // Dark Slate Blue
        accentColor: Color(red: 138/255, green: 43/255, blue: 226/255), // Blue Violet
        backgroundColor: Color(red: 248/255, green: 248/255, blue: 255/255), // Ghost White
        cardBackground: .white
    )
    
    static let cherry = AppTheme(
        name: "cherry",
        displayName: "Kiraz",
        primaryColor: Color(red: 220/255, green: 20/255, blue: 60/255), // Crimson
        secondaryColor: Color(red: 255/255, green: 105/255, blue: 180/255), // Hot Pink
        accentColor: Color(red: 255/255, green: 20/255, blue: 147/255), // Deep Pink
        backgroundColor: Color(red: 255/255, green: 245/255, blue: 250/255), // Misty Rose
        cardBackground: .white
    )
    
    static let mint = AppTheme(
        name: "mint",
        displayName: "Nane",
        primaryColor: Color(red: 0/255, green: 206/255, blue: 209/255), // Dark Turquoise
        secondaryColor: Color(red: 127/255, green: 255/255, blue: 212/255), // Aquamarine
        accentColor: Color(red: 32/255, green: 178/255, blue: 170/255), // Light Sea Green
        backgroundColor: Color(red: 240/255, green: 255/255, blue: 255/255), // Azure
        cardBackground: .white
    )
    
    static let peach = AppTheme(
        name: "peach",
        displayName: "Şeftali",
        primaryColor: Color(red: 255/255, green: 160/255, blue: 122/255), // Light Salmon
        secondaryColor: Color(red: 255/255, green: 218/255, blue: 185/255), // Peach Puff
        accentColor: Color(red: 255/255, green: 140/255, blue: 105/255), // Light Coral
        backgroundColor: Color(red: 255/255, green: 250/255, blue: 240/255), // Floral White
        cardBackground: .white
    )
    
    static let rose = AppTheme(
        name: "rose",
        displayName: "Gül",
        primaryColor: Color(red: 199/255, green: 21/255, blue: 133/255), // Medium Violet Red
        secondaryColor: Color(red: 219/255, green: 112/255, blue: 147/255), // Pale Violet Red
        accentColor: Color(red: 255/255, green: 105/255, blue: 180/255), // Hot Pink
        backgroundColor: Color(red: 255/255, green: 240/255, blue: 245/255), // Lavender Blush
        cardBackground: .white
    )
    
    static let coral = AppTheme(
        name: "coral",
        displayName: "Mercan",
        primaryColor: Color(red: 255/255, green: 127/255, blue: 80/255), // Coral
        secondaryColor: Color(red: 255/255, green: 160/255, blue: 122/255), // Light Salmon
        accentColor: Color(red: 250/255, green: 128/255, blue: 114/255), // Salmon
        backgroundColor: Color(red: 255/255, green: 248/255, blue: 240/255), // Cornsilk
        cardBackground: .white
    )
    
    static let grape = AppTheme(
        name: "grape",
        displayName: "Üzüm",
        primaryColor: Color(red: 106/255, green: 90/255, blue: 205/255), // Slate Blue
        secondaryColor: Color(red: 147/255, green: 112/255, blue: 219/255), // Medium Purple
        accentColor: Color(red: 138/255, green: 43/255, blue: 226/255), // Blue Violet
        backgroundColor: Color(red: 245/255, green: 245/255, blue: 255/255), // Lavender
        cardBackground: .white
    )
    
    static let autumn = AppTheme(
        name: "autumn",
        displayName: "Sonbahar",
        primaryColor: Color(red: 184/255, green: 134/255, blue: 11/255), // Dark Goldenrod
        secondaryColor: Color(red: 205/255, green: 133/255, blue: 63/255), // Peru
        accentColor: Color(red: 210/255, green: 105/255, blue: 30/255), // Chocolate
        backgroundColor: Color(red: 255/255, green: 250/255, blue: 240/255), // Floral White
        cardBackground: .white
    )
    
    static let berry = AppTheme(
        name: "berry",
        displayName: "Böğürtlen",
        primaryColor: Color(red: 128/255, green: 0/255, blue: 128/255), // Purple
        secondaryColor: Color(red: 186/255, green: 85/255, blue: 211/255), // Medium Orchid
        accentColor: Color(red: 218/255, green: 112/255, blue: 214/255), // Orchid
        backgroundColor: Color(red: 253/255, green: 245/255, blue: 255/255), // Magnolia
        cardBackground: .white
    )
    
    static let sky = AppTheme(
        name: "sky",
        displayName: "Gökyüzü",
        primaryColor: Color(red: 0/255, green: 191/255, blue: 255/255), // Deep Sky Blue
        secondaryColor: Color(red: 135/255, green: 206/255, blue: 250/255), // Light Sky Blue
        accentColor: Color(red: 100/255, green: 149/255, blue: 237/255), // Cornflower Blue
        backgroundColor: Color(red: 240/255, green: 248/255, blue: 255/255), // Alice Blue
        cardBackground: .white
    )
    
    static let emerald = AppTheme(
        name: "emerald",
        displayName: "Zümrüt",
        primaryColor: Color(red: 0/255, green: 201/255, blue: 87/255), // Emerald
        secondaryColor: Color(red: 46/255, green: 213/255, blue: 115/255), // Medium Aquamarine
        accentColor: Color(red: 26/255, green: 188/255, blue: 156/255), // Turquoise
        backgroundColor: Color(red: 240/255, green: 255/255, blue: 244/255), // Mint Cream
        cardBackground: .white
    )
    
    static let ruby = AppTheme(
        name: "ruby",
        displayName: "Yakut",
        primaryColor: Color(red: 224/255, green: 17/255, blue: 95/255), // Ruby
        secondaryColor: Color(red: 231/255, green: 76/255, blue: 60/255), // Alizarin
        accentColor: Color(red: 192/255, green: 57/255, blue: 43/255), // Pomegranate
        backgroundColor: Color(red: 255/255, green: 245/255, blue: 247/255), // Rose White
        cardBackground: .white
    )
    
    static let honey = AppTheme(
        name: "honey",
        displayName: "Bal",
        primaryColor: Color(red: 241/255, green: 196/255, blue: 15/255), // Sun Flower
        secondaryColor: Color(red: 243/255, green: 156/255, blue: 18/255), // Orange
        accentColor: Color(red: 230/255, green: 126/255, blue: 34/255), // Carrot
        backgroundColor: Color(red: 255/255, green: 250/255, blue: 235/255), // Lemon Chiffon
        cardBackground: .white
    )
    
    static let allThemes: [AppTheme] = [
        .romantic, .sunset, .ocean, .forest, .lavender,
        .midnight, .cherry, .mint, .peach, .rose,
        .coral, .grape, .autumn, .berry, .sky,
        .emerald, .ruby, .honey
    ]
}

