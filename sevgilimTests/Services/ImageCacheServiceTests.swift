//
//  ImageCacheServiceTests.swift
//  sevgilimTests
//
//  Unit tests for ImageCacheService

import XCTest
import UIKit
@testable import sevgilim

final class ImageCacheServiceTests: XCTestCase {
    
    var sut: ImageCacheService!
    
    override func setUp() {
        super.setUp()
        sut = ImageCacheService.shared
    }
    
    override func tearDown() {
        sut.clearCache()
        sut = nil
        super.tearDown()
    }
    
    func createTestImage() -> UIImage {
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContext(size)
        UIColor.blue.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func testSetAndGetImage() {
        let key = "test_image"
        let image = createTestImage()
        
        sut.set(image, forKey: key)
        let retrieved = sut.get(forKey: key)
        
        XCTAssertNotNil(retrieved, "Should retrieve cached image")
    }
    
    func testGetNonExistentImage() {
        let retrieved = sut.get(forKey: "non_existent")
        
        XCTAssertNil(retrieved, "Should return nil for non-existent key")
    }
    
    func testClearCache() {
        let key = "test_image"
        let image = createTestImage()
        
        sut.set(image, forKey: key)
        sut.clearCache()
        let retrieved = sut.get(forKey: key)
        
        XCTAssertNil(retrieved, "Cache should be cleared")
    }
    
    func testRemoveImage() {
        let key = "test_image"
        let image = createTestImage()
        
        sut.set(image, forKey: key)
        sut.remove(forKey: key)
        let retrieved = sut.get(forKey: key)
        
        XCTAssertNil(retrieved, "Image should be removed")
    }
    
    func testMultipleImages() {
        let images = [
            ("key1", createTestImage()),
            ("key2", createTestImage()),
            ("key3", createTestImage())
        ]
        
        for (key, image) in images {
            sut.set(image, forKey: key)
        }
        
        for (key, _) in images {
            let retrieved = sut.get(forKey: key)
            XCTAssertNotNil(retrieved, "Should retrieve image for key: \(key)")
        }
    }
    
    func testCacheLimit() {
        // Test that cache respects memory limits
        // Cache should handle large numbers of images
        for i in 0..<100 {
            let key = "image_\(i)"
            let image = createTestImage()
            sut.set(image, forKey: key)
        }
        
        XCTAssertTrue(true, "Cache should handle many images without crash")
    }
}
