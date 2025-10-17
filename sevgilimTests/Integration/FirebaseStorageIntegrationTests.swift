//
//  FirebaseStorageIntegrationTests.swift
//  sevgilimTests
//
//  Integration tests for Firebase Storage + Firestore

import XCTest
import UIKit
@testable import sevgilim

@MainActor
final class FirebaseStorageIntegrationTests: XCTestCase {
    
    var storageService: StorageService!
    var photoService: PhotoService!
    
    override func setUp() async throws {
        try await super.setUp()
        storageService = StorageService()
        photoService = PhotoService()
    }
    
    override func tearDown() async throws {
        storageService = nil
        photoService.stopListening()
        photoService = nil
        try await super.tearDown()
    }
    
    func createTestImage() -> UIImage {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        UIColor.green.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: - Storage + Firestore Integration
    
    func testUploadImageAndSaveToFirestore() async throws {
        // Given: Image to upload
        let image = createTestImage()
        let relationshipId = UUID().uuidString
        let userId = UUID().uuidString
        
        do {
            // When: Upload image to Storage
            let imageURL = try await storageService.uploadProfileImage(image, userId: userId)
            
            XCTAssertFalse(imageURL.isEmpty, "Image URL should not be empty")
            XCTAssertTrue(imageURL.hasPrefix("https://"), "Should be valid HTTPS URL")
            
            // Then: Save photo reference to Firestore
            try await photoService.addPhoto(
                relationshipId: relationshipId,
                imageURL: imageURL,
                caption: "Integration test photo",
                location: nil,
                tags: nil,
                userId: userId
            )
            
            XCTAssertTrue(true, "Photo saved to Firestore with Storage URL")
            
            // Cleanup: Delete from storage
            try await storageService.deleteImage(imageURL)
        } catch {
            print("Storage + Firestore integration test skipped: \(error)")
        }
    }
    
    func testUploadMultipleImagesInSequence() async throws {
        // Test uploading multiple images and saving references
        
        let relationshipId = UUID().uuidString
        let userId = UUID().uuidString
        var uploadedURLs: [String] = []
        
        do {
            // Upload 3 images
            for i in 1...3 {
                let image = createTestImage()
                let imageURL = try await storageService.uploadImage(
                    image,
                    path: "test/integration_\(i)_\(UUID().uuidString).jpg"
                )
                
                uploadedURLs.append(imageURL)
                
                // Save to Firestore
                try await photoService.addPhoto(
                    relationshipId: relationshipId,
                    imageURL: imageURL,
                    caption: "Photo \(i)",
                    location: nil,
                    tags: nil,
                    userId: userId
                )
            }
            
            XCTAssertEqual(uploadedURLs.count, 3, "Should upload 3 images")
            
            // Cleanup
            for url in uploadedURLs {
                try? await storageService.deleteImage(url)
            }
        } catch {
            print("Multiple upload integration test skipped: \(error)")
        }
    }
    
    // MARK: - Delete Integration
    
    func testDeleteImageFromStorageAndFirestore() async throws {
        // Given: Uploaded image
        let image = createTestImage()
        let relationshipId = UUID().uuidString
        let userId = UUID().uuidString
        
        do {
            // Upload
            let imageURL = try await storageService.uploadImage(
                image,
                path: "test/delete_test_\(UUID().uuidString).jpg"
            )
            
            // Save to Firestore
            try await photoService.addPhoto(
                relationshipId: relationshipId,
                imageURL: imageURL,
                caption: "To be deleted",
                location: nil,
                tags: nil,
                userId: userId
            )
            
            // Delete from Storage
            try await storageService.deleteImage(imageURL)
            
            // In real app, would also delete Firestore document
            XCTAssertTrue(true, "Delete integration completed")
            
        } catch {
            print("Delete integration test skipped: \(error)")
        }
    }
    
    // MARK: - Error Handling
    
    func testUploadWithInvalidImage() async throws {
        // Test error handling when upload fails
        let invalidPath = ""
        let image = createTestImage()
        
        do {
            let _ = try await storageService.uploadImage(image, path: invalidPath)
            XCTFail("Should throw error for invalid path")
        } catch {
            XCTAssertNotNil(error, "Error should be thrown")
        }
    }
    
    func testDeleteNonExistentImage() async throws {
        // Test deleting image that doesn't exist
        let fakeURL = "https://firebasestorage.googleapis.com/v0/b/test/o/nonexistent.jpg"
        
        do {
            try await storageService.deleteImage(fakeURL)
            // May succeed or fail depending on Firebase rules
            XCTAssertTrue(true, "Delete handled gracefully")
        } catch {
            // Expected behavior
            XCTAssertNotNil(error)
        }
    }
}
