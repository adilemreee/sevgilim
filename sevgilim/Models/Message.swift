//
//  Message.swift
//  sevgilim
//

import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var relationshipId: String
    var senderId: String
    var senderName: String
    var text: String
    var imageURL: String?
    var storyImageURL: String? // Story yanıtı için story resmi
    var timestamp: Date
    var isRead: Bool
    var readAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case relationshipId
        case senderId
        case senderName
        case text
        case imageURL
        case storyImageURL
        case timestamp
        case isRead
        case readAt
    }
}

// MARK: - Typing Indicator Model
struct TypingIndicator: Codable {
    var userId: String
    var userName: String
    var isTyping: Bool
    var timestamp: Date
}

