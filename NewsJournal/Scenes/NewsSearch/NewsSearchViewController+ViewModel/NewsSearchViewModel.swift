//
//  NewsSearchViewModel.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import Foundation

final class NewsSearchViewModel {
    
    //MARK: - Properties
    
    var newsList: Observable<[News]> = Observable([])
    
    var page = Observable(1)
    
    var query = Observable("")
    
    var networkErrorMessage = Observable("")
    
    var sortType = SortType.sim
    
    private let network = Network.shared
    
    //MARK: - API
    
    func callRequest() {
        
        if page.value == 1 {
            //새로운 query: 기존 검색 결과 지우기
            newsList.value.removeAll()
        }
        
        let lowerCasedQuery = query.value.lowercased()
//        guard let encodedQuery = lowerCasedQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        network.callRequest(type: NewsTotal.self, api: .newsSearch(query: lowerCasedQuery, start: page.value, sort: sortType)) { response in
            switch response {
            case .success(let success):
                if self.newsList.value.isEmpty && success.items.isEmpty {
                    //기존 검색 결과 없고 새로운 검색 결과 없는 경우: empty View 보여주기
                    print("It's empty!")
                } else {
                    self.newsList.value.append(contentsOf: success.items)
                }
            case .failure(let failure):
                self.networkErrorMessage.value = failure.errorDescription
            }
        }
    }
    
    func checkPageResetNeeded() -> Bool {
        return page.value > 1 ? true : false
    }
    
    func checkPrefetchingNeeded(_ row: Int) -> Bool {
        return newsList.value.count - 2 == row ? true : false
    }
    
}
