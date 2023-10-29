//
//  BookMarkedNewsCellViewModel.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/24.
//

import Foundation

final class BookMarkedNewsCellViewModel {
    //MARK: - Properties
    
    var bookmarkedNews: Observable<BookMarkedNews?> = Observable(nil)
    
    private let cacheManager = CacheManager.shared
    private let repository = Repository.shared
    
    //MARK: - API
    
    func checkImageInDocuments() -> Data? {
        guard let news = bookmarkedNews.value else {
            print("No News to retrieve from realm")
            return nil
        }
        
        do {
            let imageData = try cacheManager.loadFromDocuments(fileName: "\(news.nameForURL).jpg")
            return imageData
        } catch {
            return nil
        }
    }
        
    func checkJournalExistsWith(news: BookMarkedNews) -> Bool {
        return news.journal != nil ? true : false
    }
    
    //MARK: - Setup Press by News Link
    
    func mapPressWithNewsLink() -> String? {
        
        guard let news = bookmarkedNews.value else { return nil }
        
        let pressWithNewsLink = MappingURLPress.allCases.filter { news.link.contains($0.rawValue) }
        
        if pressWithNewsLink.isEmpty {
            return nil
        } else {
            return pressWithNewsLink[0].pressName
        }
    }
}
