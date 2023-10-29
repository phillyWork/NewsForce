//
//  DefaultMediaStackNewsCellViewModel.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/20.
//

import Foundation
import LinkPresentation

final class DefaultMediaStackNewsCellViewModel {
    
    //MARK: - Properties
    
    private let cacheManager = CacheManager.shared
    private let repository = Repository.shared
    
    var news: Observable<DTONews?> = Observable(nil)
    
    //MARK: - API
    
    func checkImageInDocuments() -> Data? {
        guard let news = news.value else {
            print("No News to retrieve")
            return nil
        }
        
        do {
            let imageData = try cacheManager.loadFromDocuments(fileName: "\(news.nameForURL).jpg")
            return imageData
        } catch {
            return nil
        }
    }
    
    func checkMetadataInMemoryCache() -> LPLinkMetadata? {
        guard let news = news.value else {
            print("No News to retrieve")
            return nil
        }
        
        if let metaData = cacheManager.checkMemory(news.nameForURL) {
            return metaData
        }
        
        return nil
    }
    
    func retrieveImageFromLink(metaData: LPLinkMetadata, completionHandler: @escaping (UIImage?) -> Void ) {
        if let imageProvider = metaData.imageProvider {
            imageProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let image = image as? UIImage {
                    completionHandler(image)
                }
                else {
                    completionHandler(nil)
                }
            }
        } else {
            completionHandler(nil)
        }
    }
    
    func saveImageIntoDocuments(image: UIImage) {
        guard let news = news.value else {
            print("No News to retrieve")
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: Constant.Image.jpegCompressionQuality) else { return }
        do {
            try cacheManager.saveToDocuments(fileName: "\(news.nameForURL).jpg", data: imageData)
        } catch {
            
        }
    }
    
    func saveMetadataIntoMemory(data: LPLinkMetadata) {
        guard let news = news.value else {
            print("No News to retrieve")
            return
        }
        
        cacheManager.saveIntoMemoryCache(news.nameForURL, data: data)
    }
    
    func fetchMediaNewsMetaData(url: String, completionHandler: @escaping (Result<LPLinkMetadata, LPError>) -> Void ) {
        guard let urlForFetch = URL(string: url) else { return }
        
        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: urlForFetch) { metaData, error in
            guard let data = metaData, error == nil else {
//        provider.startFetchingMetadata(for: urlForFetch) { [weak self] metaData, error in
//            guard let data = metaData, error == nil, let _ = self else {
                provider.cancel()
                if let error = error as? LPError {
                    print("error occurred, sending LPError")
                    completionHandler(.failure(error))
                } else {
                    print("can't send LPError")
                }
                return
            }
            completionHandler(.success(data))
        }
    }
    
    private func setupTempMetaData(url: String) -> LPLinkMetadata {
        let metadata = LPLinkMetadata()
        metadata.originalURL = URL(string: url)
        metadata.url = metadata.originalURL
        metadata.title = news.value?.title
        return metadata
    }

    
    //MARK: - Check Realm
    
    func checkBookMarkedNewsExists(news: DTONews) -> Bool {
        if let results = repository.fetchWithLink(link: news.urlLink), !results.isEmpty {
            return true
        }
        return false
    }
    
    func checkJournalExistsWith(news: DTONews) -> Bool {
        if let results = repository.fetchJournalWithLink(link: news.urlLink), !results.isEmpty {
            return true
        }
        return false
    }
    
    //MARK: - Setup Press by News Link
    
    func mapPressWithNewsLink() -> String? {
        
        guard let news = news.value else { return nil }
        
        let pressWithNewsLink = MappingURLPress.allCases.filter { news.urlLink.contains($0.rawValue) }

        if pressWithNewsLink.isEmpty {
            return nil
        } else {
            return pressWithNewsLink[0].pressName
        }
    }
    
    
}
