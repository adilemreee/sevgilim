//
//  ImageCacheService.swift
//  sevgilim
//
//  High-performance image caching service with memory and disk cache

import UIKit
import Foundation

actor ImageCacheService {
    static let shared = ImageCacheService()
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    // In-flight requests to prevent duplicate downloads
    private var inFlightRequests: [String: Task<UIImage?, Error>] = [:]
    
    private init() {
        // Configure memory cache
        memoryCache.countLimit = 100 // Max 100 images in memory
        memoryCache.totalCostLimit = 1024 * 1024 * 150 // 150 MB max memory usage
        
        // Setup disk cache directory
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = cachesDirectory.appendingPathComponent("ImageCache")
        
        // Create cache directory if needed
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Setup memory warning observer
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { await self?.handleMemoryWarning() }
        }
    }
    
    // MARK: - Public API
    
    /// Load image with automatic caching
    func loadImage(from urlString: String, thumbnail: Bool = false) async throws -> UIImage? {
        let cacheKey = thumbnail ? "\(urlString)_thumb" : urlString
        
        // Check memory cache first
        if let cachedImage = memoryCache.object(forKey: cacheKey as NSString) {
            return cachedImage
        }
        
        // Check disk cache
        if let diskImage = loadFromDisk(key: cacheKey) {
            // Save to memory cache
            memoryCache.setObject(diskImage, forKey: cacheKey as NSString)
            return diskImage
        }
        
        // Check if already downloading
        if let existingTask = inFlightRequests[cacheKey] {
            return try await existingTask.value
        }
        
        // Download image
        let task = Task<UIImage?, Error> {
            try await downloadAndCache(urlString: urlString, cacheKey: cacheKey, thumbnail: thumbnail)
        }
        
        inFlightRequests[cacheKey] = task
        
        defer {
            inFlightRequests.removeValue(forKey: cacheKey)
        }
        
        return try await task.value
    }
    
    /// Preload images in background (for upcoming photos)
    func preloadImages(_ urlStrings: [String], thumbnail: Bool = false) {
        Task {
            for urlString in urlStrings {
                _ = try? await loadImage(from: urlString, thumbnail: thumbnail)
            }
        }
    }
    
    /// Clear all caches
    func clearCache() async {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    /// Clear old cached items (older than 7 days)
    func clearOldCache() async {
        let sevenDaysAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.contentModificationDateKey]) else {
            return
        }
        
        for file in files {
            if let attributes = try? fileManager.attributesOfItem(atPath: file.path),
               let modificationDate = attributes[.modificationDate] as? Date,
               modificationDate < sevenDaysAgo {
                _ = try? fileManager.removeItem(at: file)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func downloadAndCache(urlString: String, cacheKey: String, thumbnail: Bool) async throws -> UIImage? {
        guard let url = URL(string: urlString) else {
            throw CacheError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard var image = UIImage(data: data) else {
            throw CacheError.invalidImageData
        }
        
        // Create thumbnail if requested
        if thumbnail {
            image = image.preparingThumbnail(of: CGSize(width: 400, height: 400)) ?? image
        }
        
        // Save to memory cache
        memoryCache.setObject(image, forKey: cacheKey as NSString)
        
        // Save to disk cache (in background)
        Task.detached(priority: .background) {
            await self.saveToDisk(image: image, key: cacheKey)
        }
        
        return image
    }
    
    private func loadFromDisk(key: String) -> UIImage? {
        let fileURL = cacheDirectory.appendingPathComponent(key.md5)
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }
    
    private func saveToDisk(image: UIImage, key: String) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let fileURL = cacheDirectory.appendingPathComponent(key.md5)
        try? data.write(to: fileURL)
    }
    
    private func handleMemoryWarning() {
        memoryCache.removeAllObjects()
    }
    
    enum CacheError: Error {
        case invalidURL
        case invalidImageData
    }
}

// MARK: - String Extension for MD5 (cache key)
extension String {
    nonisolated var md5: String {
        // Simple hash for file name
        return String(self.hash)
    }
}

// MARK: - SwiftUI Helper View
import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: String
    let thumbnail: Bool
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder
    
    @State private var loadedImage: UIImage?
    @State private var isLoading = true
    @State private var loadError: Error?
    
    init(
        url: String,
        thumbnail: Bool = false,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.thumbnail = thumbnail
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = loadedImage {
                content(Image(uiImage: image))
            } else if isLoading {
                placeholder()
            } else {
                placeholder() // Show placeholder on error too
            }
        }
        .task(id: url) {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        isLoading = true
        loadError = nil
        
        do {
            if let image = try await ImageCacheService.shared.loadImage(from: url, thumbnail: thumbnail) {
                await MainActor.run {
                    loadedImage = image
                    isLoading = false
                }
            } else {
                await MainActor.run {
                    isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                loadError = error
                isLoading = false
            }
        }
    }
}

