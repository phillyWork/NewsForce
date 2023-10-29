//
//  DefaultNaverNewsViewModel.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/14.
//

import Foundation

import RealmSwift

final class DefaultNaverNewsViewModel {
    
    //MARK: - Properties
    
    var naverNewsList: Observable<[DTONews]> = Observable([])
    
    var page = Observable(1)
    
    var errorMessage = Observable("")
    
    var isEmptyView = Observable(false)
    
    var sortType = NaverNewsSearchSortType.sim

    private let query = Date()
    
    private let network = Network.shared
    private let repository = Repository.shared
    
    //MARK: - API
    
    func checkIndexForDTONewsSavedInRealm(passedNews: DTONews) -> [IndexPath] {
        print(#function)
        var indexPathResult = [IndexPath]()
        
        for i in 0..<naverNewsList.value.count {
            if passedNews.urlLink == naverNewsList.value[i].urlLink {
                let indexPath = IndexPath(item: i, section: 0)
                indexPathResult.append(indexPath)
            }
        }
        
        print("result in default naver news indexPath: ", indexPathResult)
        
        return indexPathResult
    }
    
    func checkIndexForBookMarkedNewsSavedInRealm(passedNewsLink: String) -> [IndexPath] {
        print(#function)
        var indexPathResult = [IndexPath]()
        
        for i in 0..<naverNewsList.value.count {
            if passedNewsLink == naverNewsList.value[i].urlLink {
                let indexPath = IndexPath(item: i, section: 0)
                indexPathResult.append(indexPath)
            }
        }
        
        print("result in default naver news indexPath: ", indexPathResult)
        
        return indexPathResult
    }
    
    func checkDeletedBookmarkNewsInNaverNewsList(deleted: [String]) -> [IndexPath] {
        var indexPathResult = [IndexPath]()
        
        print("count of deleted news in searchVC: ", deleted.count)
        
        for j in 0..<deleted.count {
            for i in 0..<naverNewsList.value.count {
                if deleted[j] == naverNewsList.value[i].urlLink {
                    let indexPath = IndexPath(item: i, section: 0)
                    indexPathResult.append(indexPath)
                }
            }
        }
       
//        for i in 0..<naverNewsList.value.count {
//            if deleted == naverNewsList.value[i].urlLink {
//                let indexPath = IndexPath(item: i, section: 0)
//                return indexPath
//            }
//        }
        
        return indexPathResult
    }
    
    
    //MARK: - Network API
    
    func callRequestForNaver() {
        if page.value > Constant.APISetup.naverMaxStart {
            errorMessage.value = NewsSearchSetupValues.cannotSearchMoreThanMaxStart
            return
        }
        
        network.naverCallRequest(type: NaverNewsTotal.self, api: .naverNewsSearch(query: query.toStringForDefaultNewsForNaver(), start: page.value, sort: sortType)) { response in
            switch response {
            case .success(let success):
                if self.naverNewsList.value.isEmpty && success.items.isEmpty {
                    //기존 검색 결과 없고 새로운 검색 결과 없는 경우: empty View 보여주기
                    self.isEmptyView.value = true
                } else {
                    //DTO type으로 변환하기
                    var dtoArray = [DTONews]()
                    for item in success.items {
                        dtoArray.append(item.createDTONews())
                    }
                    self.naverNewsList.value.append(contentsOf: dtoArray)
                    self.isEmptyView.value = false
                }
            case .failure(let failure):
                self.errorMessage.value = failure.errorDescription
            }
        }
    }
    
    func checkPrefetchingNeeded(_ row: Int) -> Bool {
        return naverNewsList.value.count - 1 == row ? true : false
    }
    
    func removeCurrentDTONewsArray() {
        naverNewsList.value.removeAll()
    }
    
    func isPageAboutToReset() -> Bool {
        return page.value != 1 ? true : false
    }

    //MARK: - Realm API
    
    func checkNaverNewsExistsInRealmWithLink(news: DTONews) -> Results<BookMarkedNews>? {
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
        print(#function)
        do {
            try repository.deleteRecords(records: bookMarkedNews)
        } catch {
            //error 처리
            
        }
        
    }
        
    func saveNewsToRealm(news: DTONews) {
        print(#function)
        let bookmarkedNews = BookMarkedNews(title: news.title, newsDescription: news.description, pubDate: news.pubDate, link: news.urlLink, apiType: .naver)
        
        do {
            try repository.createRecord(record: bookmarkedNews)
        } catch {
            //error 처리
            
        }
    }
    
}
