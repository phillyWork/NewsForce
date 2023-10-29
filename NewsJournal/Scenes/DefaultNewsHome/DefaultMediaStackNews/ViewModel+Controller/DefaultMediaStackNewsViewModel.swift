//
//  DefaultMediaStackNewsViewModel.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/14.
//

import Foundation

import RealmSwift

final class DefaultMediaStackNewsViewModel {
    
    var mediaNewsList: Observable<[DTONews]> = Observable([])
    
    var offset = Observable(0)
    
    var apiKeyIndex = Observable(0)
    
    var errorMessage = Observable("")
    
    var isEmptyView = Observable(false)

    private let network = Network.shared
    private let repository = Repository.shared
    
    private var totalCountForTodayNews = 0
    
    //MARK: - API
    
    func checkIndexForDTONewsSavedInRealm(passedNews: DTONews) -> [IndexPath] {
        print(#function)
        var indexPathResult = [IndexPath]()
        
        for i in 0..<mediaNewsList.value.count {
            if passedNews.urlLink == mediaNewsList.value[i].urlLink {
                let indexPath = IndexPath(item: i, section: 0)
                indexPathResult.append(indexPath)
            }
        }
        
        print("result in media stack news indexPath: ", indexPathResult)
        
        return indexPathResult
    }
    
    func checkIndexForBookMarkedNewsSavedInRealm(passedNewsLink: String) -> [IndexPath] {
        print(#function)
        var indexPathResult = [IndexPath]()
        
        for i in 0..<mediaNewsList.value.count {
            if passedNewsLink == mediaNewsList.value[i].urlLink {
                let indexPath = IndexPath(item: i, section: 0)
                indexPathResult.append(indexPath)
            }
        }
        
        print("result in media stack news indexPath: ", indexPathResult)
        
        return indexPathResult
    }
    
    func checkDeletedBookmarkNewsInMediaStackNewsList(deleted: [String]) -> [IndexPath] {
            
        print("count of deleted news in searchVC: ", deleted.count)
        
        var indexPathResult = [IndexPath]()
        
        for j in 0..<deleted.count {
            for i in 0..<mediaNewsList.value.count {
                if deleted[j] == mediaNewsList.value[i].urlLink {
                    let indexPath = IndexPath(item: i, section: 0)
                    indexPathResult.append(indexPath)
                }
            }
        }
        
//            for i in 0..<mediaNewsList.value.count {
//                if deleted == mediaNewsList.value[i].urlLink {
//                    let indexPath = IndexPath(item: i, section: 0)
//                    return indexPath
//                }
//            }
        
        return indexPathResult
    }
    
    //MARK: - Network API
    
    func callRequestForMediaStack() {
        print(#function)
        
        if offset.value > totalCountForTodayNews {
            //시작 위치가 offset보다 더 클 수는 없음: 에러 발생
            errorMessage.value = NewsSearchSetupValues.cannotSearchMoreThanMaxStart
            return
        }
        
        network.mediaStackCallRequest(type: MediaStackNewsTotal.self, api: .mediaStackDefaultLiveNews(today: Date(), offset: offset.value, keyIndex: apiKeyIndex.value)) { response in
            print("mediaStackCallRequest done!")
            switch response {
            case .success(let success):
                print("data retrieval success")
                if self.mediaNewsList.value.isEmpty && success.data.isEmpty {
                    self.isEmptyView.value = true
                } else {
                    var dtoArray = [DTONews]()
                    for item in success.data {
                        dtoArray.append(item.createDTONews())
                    }
                    self.mediaNewsList.value.append(contentsOf: dtoArray)
                    self.totalCountForTodayNews = success.pagination.total
                    self.isEmptyView.value = false
                }
            case .failure(let failure):
                print("failed to retreive media stack news from network")
                if failure == MediaStackNetworkError.usage_limit_reached && self.apiKeyIndex.value < APIKey.mediaStackAccessKeys.count {
                    self.apiKeyIndex.value += 1
                } else {
                    self.errorMessage.value = failure.errorDescription
                }
            }
        }
    }
    
    func checkPrefetchingNeeded(_ row: Int) -> Bool {
        return mediaNewsList.value.count - 2 == row ? true : false
    }
    
    func removeCurrentDTONewsArray() {
        mediaNewsList.value.removeAll()
    }
    
    func isOffsetAboutToReset() -> Bool {
        return offset.value != 1 ? true : false
    }
    
    //MARK: - Realm API
    
    func checkMediaStackNewsExistsInRealmWithLink(news: DTONews) -> Results<BookMarkedNews>? {
        if let results = repository.fetchWithLink(link: news.urlLink), !results.isEmpty {
            return results
        }
        return nil
    }
    
    func checkMemoExistsWithLink(bookMarked: Results<BookMarkedNews>) -> Bool {
        let resultsInArray = Array(bookMarked)
        print("count of results: ", resultsInArray.count)
        for bookmarkedNews in resultsInArray {
            if let _ = bookmarkedNews.journal {
                return true
            }
        }
        return false
    }
    
    func removeBookMarkedNewsFromRealm(bookMarkedNews: Results<BookMarkedNews>) {
        do {
            try repository.deleteRecords(records: bookMarkedNews)
        } catch {
            //error 처리
            
        }
        
    }
        
    func saveNewsToRealm(news: DTONews) {
        let bookmarkedNews = BookMarkedNews(title: news.title, newsDescription: news.description, pubDate: news.pubDate, link: news.urlLink, apiType: .mediaStack)
        
        do {
            try repository.createRecord(record: bookmarkedNews)
        } catch {
            //error 처리
            
        }
    }
    
    
}
