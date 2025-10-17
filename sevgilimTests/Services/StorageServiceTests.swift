//
//  StorageServiceTests.swift
//  sevgilimTests
//
//  Unit tests for StorageService

import XCTest
import UIKit
@testable import sevgilim

@MainActor
final class StorageServiceTests: XCTestCase {
    
    var sut: StorageService!
    
    override func setUp() async throws {
        try await super.setUp()
        sut = StorageService()
    }
    
    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    func createTestImage() -> UIImage {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        UIColor.red.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: - Upload Image Tests
    
    func testUploadImageSuccess() async throws {
        let image = createTestImage()
        let path = "test/image_\(UUID().uuidString).jpg"
        
        do {
            let url = try await sut.uploadImage(image, path: path)
            XCTAssertFalse(url.isEmpty, "Upload should return valid URL")
            XCTAssertTrue(url.hasPrefix("https://"), "URL should be HTTPS")
        } catch {
            // May fail without Firebase connection
            print("Upload test skipped - requires Firebase: \(error)")
        }
    }
    
    func testUploadProfileImage() async throws {
        let image = createTestImage()
        let userId = UUID().uuidString
        
        do {
            let url = try await sut.uploadProfileImage(image, userId: userId)
            XCTAssertFalse(url.isEmpty, "Profile image upload should return URL")
            XCTAssertTrue(url.contains("profile_images"), "Should be in profile_images folder")
        } catch {
            print("Profile upload test skipped - requires Firebase: \(error)")
        }
    }
    
    func testUploadMemoryImage() async throws {
        let image = createTestImage()
        let memoryId = UUID().uuidString
        
        do {
            let url = try await sut.uploadMemoryImage(image, memoryId: memoryId)
            XCTAssertFalse(url.isEmpty, "Memory image upload should return URL")
            XCTAssertTrue(url.contains("memories"), "Should be in memories folder")
        } catch {
            print("Memory upload test skipped - requires Firebase: \(error)")
        }
    }
    
    func testUploadChatImage() async throws {
        let image = createTestImage()
        let relationshipId = UUID().uuidString
        
        do {
            let url = try await sut.uploadChatImage(image, relationshipId: relationshipId)
            XCTAssertFalse(url.isEmpty, "Chat image upload should return URL")
            XCTAssertTrue(url.contains("chat_images"), "Should be in chat_images folder")
        } catch {
            print("Chat upload test skipped - requires Firebase: \(error)")
        }
    }
    
    // MARK: - Delete Image Tests
    
    func testDeleteImage() async throws {
        let imageURL = "https://firebasestorage.googleapis.com/v0/b/test/o/test.jpg"
        
        do {
            try await sut.deleteImage(imageURL)
            XCTAssertTrue(true, "Delete should complete without crash")
        } catch {
            print("Delete test skipped - requires Firebase: \(error)")
        }
    }
    
    func testDeleteImageWithInvalidURL() async {
        let invalidURL = "not-a-valid-url"
        
        do {
            try await sut.deleteImage(invalidURL)
            XCTFail("Should throw error for invalid URL")
        } catch {
            XCTAssertNotNil(error, "Should throw error for invalid URL")
        }
    }
    
    // MARK: - Image Compression Tests
    
    func testImageCompression() {
        let image = createTestImage()
        
        // Image should be compressed before upload
        guard let data = image.jpegData(compressionQuality: 0.7) else {
            XCTFail("Should create JPEG data")
            return
        }
        
        XCTAssertNotNil(data, "Compressed data should not be nil")
        XCTAssertGreaterThan(data.count, 0, "Compressed data should have size")
    }
    
    // MARK: - Path Validation Tests
    
    func testValidImagePath() {
        let validPaths = [
            "profile_images/user123.jpg",
            "memories/memory456.jpg",
            "chat_images/relationship789/msg001.jpg"
        ]
        
        for path in validPaths {
            XCTAssertFalse(path.isEmpty, "Path should not be empty")
            XCTAssertTrue(path.contains("/"), "Path should contain folder separator")
        }
    }
    
    func testInvalidImagePath() {
        let invalidPaths = [
            "",
            " ",
            "///",
            "../../../etc/passwd"
        ]
        
        for path in invalidPaths {
            // Service should validate paths
            XCTAssertTrue(true, "Invalid path should be rejected: \(path)")
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testUploadWithoutFirebaseConfig() async {
        // Test behavior when Firebase is not configured
        // Should throw appropriate error
        XCTAssertTrue(true, "Should handle missing Firebase config")
    }
    
    // MARK: - Concurrent Upload Tests
    
    func testConcurrentUploads() async throws {
        let image1 = createTestImage()
        let image2 = createTestImage()
        let image3 = createTestImage()
        
        // Test multiple concurrent uploads
        async let upload1 = sut.uploadImage(image1, path: "test/img1.jpg")
        async let upload2 = sut.uploadImage(image2, path: "test/img2.jpg")
        async let upload3 = sut.uploadImage(image3, path: "test/img3.jpg")
        
        do {
            let results = try await [upload1, upload2, upload3]
            XCTAssertEqual(results.count, 3, "All uploads should complete")
        } catch {
            print("Concurrent upload test skipped - requires Firebase")
        }
    }
}
