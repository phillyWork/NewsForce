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
    
    var errorMessage = Observable("")
    
    var isEmptyView = Observable(false)
    
    var sortType = SortType.sim
    
    private let network = Network.shared
    
    //MARK: - API
    
    func callRequest() {
        
        if page.value == 1 {
            //새로운 query: 기존 검색 결과 지우기
            newsList.value.removeAll()
        }
        
        if page.value > Constant.APISetup.maxStart {
            errorMessage.value = NewsSearchSetupValues.cannotSearchMoreThanMaxStart
            return
        }
        
        let lowerCasedQuery = query.value.lowercased()
//        guard let encodedQuery = lowerCasedQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        network.callRequest(type: NewsTotal.self, api: .newsSearch(query: lowerCasedQuery, start: page.value, sort: sortType)) { response in
            switch response {
            case .success(let success):
                if self.newsList.value.isEmpty && success.items.isEmpty {
                    //기존 검색 결과 없고 새로운 검색 결과 없는 경우: empty View 보여주기
                    self.isEmptyView.value = true
                } else {
                    self.newsList.value.append(contentsOf: success.items)
                    self.isEmptyView.value = false
                }
            case .failure(let failure):
                self.errorMessage.value = failure.errorDescription
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
