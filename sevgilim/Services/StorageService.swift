//
//  StorageService.swift
//  sevgilim
//

import Foundation
import FirebaseStorage
import UIKit

class StorageService {
    static let shared = StorageService()
    private let storage = Storage.storage()
    
    private init() {}
    
    // MARK: - Optimized Image Upload with Compression
    
    /// Upload image with automatic optimization
    func uploadImage(_ image: UIImage, path: String, quality: CGFloat = 0.75) async throws -> String {
        // Optimize image before upload
        let optimizedImage = optimizeImage(image, maxDimension: 2048)
        
        guard let imageData = optimizedImage.jpegData(compressionQuality: quality) else {
            throw StorageError.invalidImage
        }
        
        let storageRef = storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        metadata.cacheControl = "public, max-age=31536000" // 1 year cache
        
        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        
        return downloadURL.absoluteString
    }
    
    /// Upload image with thumbnail for faster grid loading
    func uploadImageWithThumbnail(_ image: UIImage, path: String) async throws -> (fullURL: String, thumbURL: String) {
        // Generate thumbnail
        let thumbnail = generateThumbnail(from: image, maxSize: 400)
        
        // Upload both in parallel
        async let fullUpload = uploadImage(image, path: path, quality: 0.75)
        async let thumbUpload = uploadImage(thumbnail, path: path.replacingOccurrences(of: ".jpg", with: "_thumb.jpg"), quality: 0.6)
        
        let (fullURL, thumbURL) = try await (fullUpload, thumbUpload)
        return (fullURL, thumbURL)
    }
    
    func uploadProfileImage(_ image: UIImage, userId: String) async throws -> String {
        let path = "profiles/\(userId)/profile.jpg"
        return try await uploadImage(image, path: path, quality: 0.7)
    }
    
    func uploadPhoto(_ image: UIImage, relationshipId: String) async throws -> String {
        let photoId = UUID().uuidString
        let path = "relationships/\(relationshipId)/photos/\(photoId).jpg"
        return try await uploadImage(image, path: path)
    }
    
    func uploadMemoryPhoto(_ image: UIImage, relationshipId: String) async throws -> String {
        let photoId = UUID().uuidString
        let path = "relationships/\(relationshipId)/memories/\(photoId).jpg"
        return try await uploadImage(image, path: path)
    }
    
    func deleteImage(url: String) async throws {
        let storageRef = storage.reference(forURL: url)
        try await storageRef.delete()
    }
    
    // MARK: - Image Optimization Helpers
    
    private func optimizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        
        // If image is already smaller, return as is
        if size.width <= maxDimension && size.height <= maxDimension {
            return image
        }
        
        // Calculate new size maintaining aspect ratio
        let ratio = size.width / size.height
        let newSize: CGSize
        
        if size.width > size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / ratio)
        } else {
            newSize = CGSize(width: maxDimension * ratio, height: maxDimension)
        }
        
        // Resize image
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    private func generateThumbnail(from image: UIImage, maxSize: CGFloat) -> UIImage {
        let size = image.size
        let ratio = size.width / size.height
        
        let thumbnailSize: CGSize
        if size.width > size.height {
            thumbnailSize = CGSize(width: maxSize, height: maxSize / ratio)
        } else {
            thumbnailSize = CGSize(width: maxSize * ratio, height: maxSize)
        }
        
        let renderer = UIGraphicsImageRenderer(size: thumbnailSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: thumbnailSize))
        }
    }
    
    enum StorageError: Error {
        case invalidImage
        case uploadFailed
    }
}

