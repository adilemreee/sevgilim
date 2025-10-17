//
//  Story.swift
//  sevgilim
//

import Foundation
import FirebaseFirestore

struct Story: Identifiable, Codable {
    @DocumentID var id: String?
    let photoURL: String
    let thumbnailURL: String?
    let createdBy: String // userId
    let createdByName: String
    let createdByPhotoURL: String?
    let relationshipId: String
    let createdAt: Date
    var viewedBy: [String] // userId array
    
    enum CodingKeys: String, CodingKey {
        case id
        case photoURL
        case thumbnailURL
        case createdBy
        case createdByName
        case createdByPhotoURL
        case relationshipId
        case createdAt
        case viewedBy
    }
    
    // 24 saat geçti mi?
    var isExpired: Bool {
        let expiryTime: TimeInterval = 24 * 60 * 60 // 24 saat
        return Date().timeIntervalSince(createdAt) > expiryTime
    }
    
    // Kaç saat önce paylaşıldı?
    var timeAgoText: String {
        let interval = Date().timeIntervalSince(createdAt)
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours) saat önce"
        } else if minutes > 0 {
            return "\(minutes) dakika önce"
        } else {
            return "Az önce"
        }
    }
    
    // Kalan süre (24 saatten)
    var remainingTime: String {
        let expiryTime: TimeInterval = 24 * 60 * 60
        let elapsed = Date().timeIntervalSince(createdAt)
        let remaining = expiryTime - elapsed
        
        if remaining <= 0 {
            return "Süresi doldu"
        }
        
        let hours = Int(remaining / 3600)
        let minutes = Int((remaining.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours) saat kaldı"
        } else {
            return "\(minutes) dakika kaldı"
        }
    }
    
    // Bu user story'yi gördü mü?
    func isViewedBy(userId: String) -> Bool {
        return viewedBy.contains(userId)
    }
}
