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
    
    private init() {
        memoryCache.totalCostLimit = 100000
    }
    
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
        //setting totalCostLimit, NSCache will automatically calculate size with each data and remove biggest size
        //LPLinkMetadata: News data ~ 소모성 큼, etag 활용 어려움 --> 사이즈로 관리
        memoryCache.setObject(data, forKey: NSString(string: url), cost: size)
    }
    
}
