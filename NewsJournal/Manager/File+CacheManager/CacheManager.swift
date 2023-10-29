//
//  CacheManager.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/15.
//

import Foundation
import LinkPresentation

final class CacheManager {
    
    static let shared = CacheManager()
    private init() { }
    
    private let memoryCache = NSCache<NSString, LPLinkMetadata>()
    
    //MARK: - API
    
    //캐싱 체크
    func checkMemory(_ url: String) -> LPLinkMetadata? {
        let cacheKey = NSString(string: url)
        if let cachedData = memoryCache.object(forKey: cacheKey) {
            return cachedData
        }
        return nil
    }
    
    func saveIntoMemoryCache(_ url: String, data: LPLinkMetadata) {
        let size = MemoryLayout.size(ofValue: data)
        memoryCache.setObject(data, forKey: NSString(string: url), cost: size)
    }
    
}
