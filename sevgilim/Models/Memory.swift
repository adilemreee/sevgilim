//
//  Memory.swift
//  sevgilim
//

import Foundation
import FirebaseFirestore

struct Memory: Identifiable, Codable {
    @DocumentID var id: String?
    var relationshipId: String
    var title: String
    var content: String
    var date: Date
    var photoURL: String?
    var location: String?
    var tags: [String]?
    var createdBy: String // userId
    var createdAt: Date
    var likes: [String] // Array of userIds who liked
    var comments: [Comment]
    
    enum CodingKeys: String, CodingKey {
        case id
        case relationshipId
        case title
        case content
        case date
        case photoURL
        case location
        case tags
        case createdBy
        case createdAt
        case likes
        case comments
    }
}

struct Comment: Identifiable, Codable {
    var id: String = UUID().uuidString
    var userId: String
    var userName: String
    var text: String
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case userName
        case text
        case createdAt
    }
}

