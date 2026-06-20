//
//  ImageCacheManager.swift
//  Test Weather
//
//  Created by Pavel Puchkov on 20.06.2026.
//

import UIKit
import Foundation

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let lock = NSLock()
    private var cacheDirectory: URL?
    
    private init() {}
    
    private func getCacheDirectory() -> URL {
        if let existingDir = cacheDirectory {
            return existingDir
        }
        
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let cacheDir = cachesURL.appendingPathComponent("ImageCache", isDirectory: true)
        
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true, attributes: nil)
        cacheDirectory = cacheDir
        return cacheDir
    }
    
    func getImage(for key: String) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }
        
        let fileName = String(key.hashValue)
        let fileURL = getCacheDirectory().appendingPathComponent(fileName)
        
//        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        // Современный вариант для iOS 16+
        guard FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) else { return nil }

        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
    
    func saveImage(_ image: UIImage, for key: String) {
        lock.lock()
        defer { lock.unlock() }
        
        guard let data = image.pngData() ?? image.jpegData(compressionQuality: 0.8) else { return }
        
        let fileName = String(key.hashValue)
        let fileURL = getCacheDirectory().appendingPathComponent(fileName)
        
        try? data.write(to: fileURL, options: .atomic)
    }
}
