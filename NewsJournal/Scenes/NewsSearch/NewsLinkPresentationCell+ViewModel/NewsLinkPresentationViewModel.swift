//
//  NewsLinkPresentationViewModel.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/02.
//

import Foundation
import LinkPresentation

final class NewsLinkPresentationViewModel {
    
    //MARK: - Properties
    
    private let cacheManager = NSCache<NSString, LPLinkMetadata>()
    
    var news: Observable<News?> = Observable(nil)
    
    //MARK: - Handlers
    
    func fetchData(url: String, completionHandler: @escaping (Result<LPLinkMetadata, LPError>) -> Void ) {
        
        self.fetchMetaDataFromURL(url: url) { response in
            switch response {
            case .success(let data):
                completionHandler(.success(data))
            case .failure(let error):
                if error.code == .metadataFetchFailed {
                    completionHandler(.success(self.setupTempMetaData(url: url)))
                } else {
                    completionHandler(.failure(error))
                }
            }
        }
    }
    
    private func fetchMetaDataFromURL(url: String, completionHandler: @escaping (Result<LPLinkMetadata, LPError>) -> Void ) {
        
        if let cachedMetaData = checkCache(url) {
            completionHandler(.success(cachedMetaData))
            return
        }
        
        //cache에 없다면 link로 metadata 가져오기
        guard let urlForFetch = URL(string: url) else { return }
        
        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: urlForFetch) { [weak self] metaData, error in
            guard let data = metaData, error == nil, let self = self else {
                provider.cancel()
                if let error = error as? LPError {
                    completionHandler(.failure(error))
                }
                return
            }
            
            //해당 metadata cache에 저장
            self.cacheManager.setObject(data, forKey: NSString(string: url))
            completionHandler(.success(data))
        }
    }
    
    private func checkCache(_ url: String) -> LPLinkMetadata? {
        let cacheKey = NSString(string: url)
        if let cachedData = cacheManager.object(forKey: cacheKey) {
            return cachedData
        }
        return nil
    }
    
    private func setupTempMetaData(url: String) -> LPLinkMetadata {
        let metadata = LPLinkMetadata()
        metadata.originalURL = URL(string: url)
        metadata.url = metadata.originalURL
        metadata.title = news.value?.title
        return metadata
    }
    
}
