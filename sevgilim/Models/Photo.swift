//
//  Photo.swift
//  sevgilim
//

import Foundation
import FirebaseFirestore

struct Photo: Identifiable, Codable {
    @DocumentID var id: String?
    var relationshipId: String
    var imageURL: String
    var thumbnailURL: String?
    var title: String?
    var date: Date
    var location: String?
    var tags: [String]?
    var uploadedBy: String // userId
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case relationshipId
        case imageURL
        case thumbnailURL
        case title
        case date
        case location
        case tags
        case uploadedBy
        case createdAt
    }
}

