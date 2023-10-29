//
//  NewsSearchViewModel.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import Foundation

import RealmSwift

final class NewsSearchViewModel {
    
    //MARK: - Properties
    
    var newsList: Observable<[DTONews]> = Observable([])

    var errorMessage = Observable("")
    
    var isEmptyView = Observable(false)
    
    private var tempForUpdateSearchType = SearchAPIType.naver
    private var searchType = SearchAPIType.naver
    
    var yPosForHidingOptionView: CGFloat = 0
    
    private let network = Network.shared
    private let repository = Repository.shared
    
    //NaverAPI
    
    var naverQuery = Observable("")
    
    var naverPage = Observable(1)

    private var sortTypeForNaver = NaverNewsSearchSortType.sim
    private var tempForUpdateSortTypeNaver = NaverNewsSearchSortType.sim
    
    //NewsAPI
    
    var newsAPIQuery = Observable("")
    
    var newsAPIPage = Observable(1)
    
    var newsAPIApiKeyIndex = Observable(0)
    
    private var tempForUpdateNewsAPISortType = NewsAPISearchSortType.publishedAt
    private var newsAPISortType = NewsAPISearchSortType.publishedAt
    
    private var tempForUpdateNewsAPIQueryBlankReplacementType = NewsAPISearchQueryBlankReplacementType.asOr
    private var newsAPIQueryBlankReplacementType = NewsAPISearchQueryBlankReplacementType.asOr

    private var totalResultsForNewsAPISearch = 0
    
    //MARK: - API
    
    func checkIndexForDTONewsSavedInRealm(passedNews: DTONews) -> [IndexPath] {
        print(#function)
        var indexPathResult = [IndexPath]()
        
        for i in 0..<newsList.value.count {
            if passedNews.urlLink == newsList.value[i].urlLink {
                let indexPath = IndexPath(item: i, section: 0)
                indexPathResult.append(indexPath)
            }
        }
        
        print("result in search news indexPath: ", indexPathResult)
        
        return indexPathResult
    }
    
    func checkIndexForBookMarkedNewsSavedInRealm(passedNewsLink: String) -> [IndexPath] {
        print(#function)
        var indexPathResult = [IndexPath]()
        
        for i in 0..<newsList.value.count {
            if passedNewsLink == newsList.value[i].urlLink {
                let indexPath = IndexPath(item: i, section: 0)
                indexPathResult.append(indexPath)
            }
        }
        
        print("result in search news indexPath: ", indexPathResult)
        
        return indexPathResult
    }
    
   
    func checkDeletedBookmarkNewsInSearchNewsList(deleted: [String]) -> [IndexPath] {
        
        print("count of deleted news in searchVC: ", deleted.count)
        
        var indexPathResult = [IndexPath]()
        
        for j in 0..<deleted.count {
            for i in 0..<newsList.value.count {
                if deleted[j] == newsList.value[i].urlLink {
                    let indexPath = IndexPath(item: i, section: 0)
                    indexPathResult.append(indexPath)
                }
            }
        }
        
        
//            for i in 0..<newsList.value.count {
//                if deleted == newsList.value[i].urlLink {
//                    let indexPath = IndexPath(item: i, section: 0)
//                    return indexPath
//                }
//            }
        
        return indexPathResult
    }
    
    func checkNaverPageResetNeeded() -> Bool {
        return naverPage.value > 1 ? true : false
    }
    
    func checkNewsAPIPageResetNeeded() -> Bool {
        return newsAPIPage.value > 1 ? true : false
    }
    
    func checkPrefetchingNeeded(_ row: Int) -> Bool {
        return newsList.value.count - 2 == row ? true : false
    }

    func checkCurrentSearchAPI() -> SearchAPIType {
        return searchType
    }
    
    func checkCurrentNaverSortType() -> NaverNewsSearchSortType {
        return sortTypeForNaver
    }
    
    func checkCurrentNewsAPISortType() -> NewsAPISearchSortType {
        return newsAPISortType
    }
    
    func checkCurrentNewsAPISearchType() -> NewsAPISearchQueryBlankReplacementType {
        return newsAPIQueryBlankReplacementType
    }
    
    func saveSearchTypeAPI(type: SearchAPIType) {
        tempForUpdateSearchType = type
    }
    
    func setSearchTypeAPI() {
        searchType = tempForUpdateSearchType
    }
    
    func saveNaverSortType(type: NaverNewsSearchSortType) {
        tempForUpdateSortTypeNaver = type
    }
    
    func setNaverSortType() {
        sortTypeForNaver = tempForUpdateSortTypeNaver
    }
    
    func saveNewsAPISortBy(type: NewsAPISearchSortType) {
        tempForUpdateNewsAPISortType = type
    }
    
    func setNewsAPISortBy() {
        newsAPISortType = tempForUpdateNewsAPISortType
    }
    
    func saveNewsAPISearchWordTypeBy(type: NewsAPISearchQueryBlankReplacementType) {
        newsAPIQueryBlankReplacementType = type
    }
    
    func setNewsAPISearchWordTypeBy() {
        newsAPIQueryBlankReplacementType = tempForUpdateNewsAPIQueryBlankReplacementType
    }
    
    func resetNaverAPISortType() {
        sortTypeForNaver = .sim
    }
    
    func resetNewsAPISortType() {
        newsAPISortType = .publishedAt
    }
    
    func resetNewsAPISearchWordType() {
        newsAPIQueryBlankReplacementType = .asOr
    }
    
    
    //MARK: - Network API
    
    func callRequest() {
        switch searchType {
        case .naver:
            callRequestForNaver()
        case .newsAPI:
            callRequestForNewsAPI()
        }
    }
    
    private func callRequestForNewsAPI() {
        
        if newsAPIPage.value == 1 {
            //새로운 query: 기존 검색 결과 지우기
            newsList.value.removeAll()
        }
        
        let currentTotal = newsAPIPage.value * Constant.APISetup.newsAPIPageSize
        
        if newsAPIPage.value > 1 && currentTotal > totalResultsForNewsAPISearch {
            //시작 위치가 offset보다 더 클 수는 없음: 에러 발생
            errorMessage.value = NewsSearchSetupValues.cannotSearchMoreThanMaxStart
            return
        }
        
        let lowerCasedQuery = newsAPIQuery.value.lowercased()
        guard let encodedQuery = lowerCasedQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        let queryReplacedBlankWith = newsAPIQueryBlankReplacementType == .asAnd ? encodedQuery.toAddANDInSpaceBetweenQueryWordsForNewsAPI() : encodedQuery.toAddORInSpaceBetweenQueryWordsForNewsAPI()
        
        print("final for query: ", queryReplacedBlankWith)
        
        network.newsAPICallRequest(type: NewsAPITotal.self, api: .newsSearch(query: queryReplacedBlankWith, keyIndex: newsAPIApiKeyIndex.value, page: newsAPIPage.value, sortBy: newsAPISortType)) { response in
            switch response {
            case .success(let success):
                
                guard let articles = success.articles, let totalResults = success.totalResults else {
                    print("No data from success!")
                    return
                }
                
                if self.newsList.value.isEmpty && articles.isEmpty {
                    self.isEmptyView.value = true
                } else {
                    var dtoArray = [DTONews]()
                    for item in articles {
                        dtoArray.append(item.createDTO())
                    }
                    self.newsList.value.append(contentsOf: dtoArray)
                    self.totalResultsForNewsAPISearch = totalResults
                    self.isEmptyView.value = false
                }
            case .failure(let failure):
                if failure == NewsAPINetworkError.apiKeyExhausted && self.newsAPIApiKeyIndex.value < APIKey.newsAPIAccessKeys.count {
                    self.newsAPIApiKeyIndex.value += 1
                } else {
                    self.errorMessage.value = failure.alertMessage
                }
            }
        }
    }
    
    private func callRequestForNaver() {
        
        if naverPage.value == 1 {
            //새로운 query: 기존 검색 결과 지우기
            newsList.value.removeAll()
        }
        
        if naverPage.value > Constant.APISetup.naverMaxStart {
            errorMessage.value = NewsSearchSetupValues.cannotSearchMoreThanMaxStart
            return
        }
        
        let lowerCasedQuery = naverQuery.value.lowercased()
                
        network.naverCallRequest(type: NaverNewsTotal.self, api: .naverNewsSearch(query: lowerCasedQuery, start: naverPage.value, sort: sortTypeForNaver)) { response in
            switch response {
            case .success(let success):
                if self.newsList.value.isEmpty && success.items.isEmpty {
                    //기존 검색 결과 없고 새로운 검색 결과 없는 경우: empty View 보여주기
                    self.isEmptyView.value = true
                } else {
                    //DTO로 변환
                    var dtoArray = [DTONews]()
                    for item in success.items {
                        dtoArray.append(item.createDTONews())
                    }
                    self.newsList.value.append(contentsOf: dtoArray)
                    self.isEmptyView.value = false
                }
            case .failure(let failure):
                self.errorMessage.value = failure.errorDescription
            }
        }
    }

    //MARK: - Realm API
    
    func checkBookMarkedNewsExistWithLink(news: DTONews) -> Results<BookMarkedNews>? {
        if let results = repository.fetchWithLink(link: news.urlLink), !results.isEmpty {
            return results
        }
        return nil
    }
    
    func checkMemoExistsInBookMarkedNewsWithLink(bookMarked: Results<BookMarkedNews>) -> Bool {
        let resultsInArray = Array(bookMarked)
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
            errorMessage.value = RealmError.deleteObjectFailure.alertMessage
        }
    }
        
    func saveNewsToRealm(news: DTONews) {
        
        var bookmarkedNews: BookMarkedNews
        
        switch searchType {
        case .naver:
            bookmarkedNews = BookMarkedNews(title: news.title, newsDescription: news.description, pubDate: news.pubDate, link: news.urlLink, apiType: .naver)
        case .newsAPI:
            bookmarkedNews = BookMarkedNews(title: news.title, newsDescription: news.description, pubDate: news.pubDate, link: news.urlLink, apiType: .newsAPI)
        }
        
        do {
            try repository.createRecord(record: bookmarkedNews)
        } catch {
            //error 처리
            errorMessage.value = RealmError.createObjectFailure.alertMessage
        }
    }
    
    //MARK: - API for SearchWords Realm
    
    func deleteSearchWords() {
        
        //최근 검색어 나타내는 collectionView의 해당 cell X 버튼 탭 --> 해당 cell indexPath에 해당하는 item 받아와서 realm에 삭제 요청하기
        //compositional layout 사용 시, update snapshot 먼저 수행하고 삭제할 것
        
        
//        switch searchType {
//        case .naver:
//            do {
//
//            } catch {
//
//            }
//        case .newsAPI:
//            do {
//
//            } catch {
//
//            }
//        }
    }
    
    func updateSearchWords() {
        
        switch searchType {
        case .naver:
            if let keyword = repository.fetchSavedSearchWordsWithKeyword(word: naverQuery.value.lowercased()) {
                //존재한다면 횟수 증가하기
                do {
                    try repository.updateUserSearchKeyword(task: ["searchWord": keyword.searchWord, "searchWordCount": keyword.searchWordCount + 1, "lastlySearchedAt": Date()])
                } catch {
                    //검색 횟수 증가 오류
                    print("update naver search word failure")
                }
            } else {
                //존재하지 않다면 새로 등록하기
                do {
                    try repository.createRecord(record: UserSearchKeyword(searchWord: naverQuery.value.lowercased(), lastlySearchedAt: Date()))
                } catch {
                    //검색어 저장 오류
                    print("create naver search word failure")
                }
            }
        case .newsAPI:
            if let keyword = repository.fetchSavedSearchWordsWithKeyword(word: newsAPIQuery.value.lowercased()) {
                //존재한다면 횟수 증가하기
                do {
                    try repository.updateUserSearchKeyword(task: ["searchWord": keyword.searchWord, "searchWordCount": keyword.searchWordCount + 1, "lastlySearchedAt": Date()])
                } catch {
                    print("update news api search word failure")
                }
            } else {
                //존재하지 않다면 새로 등록하기
                do {
                    try repository.createRecord(record: UserSearchKeyword(searchWord: newsAPIQuery.value.lowercased(), lastlySearchedAt: Date()))
                } catch {
                    print("create news api search word failure")
                }
            }
        }
    }
    
}
