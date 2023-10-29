//
//  WebViewModel.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import Foundation

import RealmSwift

final class WebViewModel {
    
    //MARK: - Properties
    
    var news: DTONews?
    var objectId: ObjectId?
    
    var webErrorMessage = Observable("")
        
    private var currentAPIType: APIType = .naver
    
    private let repository = Repository.shared
    
    //MARK: - API
    
    func retrieveLinkFromPassedData() throws -> String {
        
        if let id = objectId {
            do {
                let journal = try retrieveJournal(id)
                return journal.link
            } catch {
                throw WebViewError.noJournalToRetrieve
            }
        } else {
            guard let news = news else { throw WebViewError.noNewsToRetrieve }
            return news.urlLink
        }
    }
    
    func retrieveJournal(_ objectId: ObjectId) throws -> BookMarkedNews {
        if let journal = repository.fetchSingleRecord(objectId: objectId) {
            return journal
        } else {
            throw WebViewError.noJournalToRetrieve
        }
    }
    
    func updateAPITypeToNaver() {
        currentAPIType = .naver
    }
    
    func updateAPITypeToMediaStack() {
        currentAPIType = .mediaStack
    }
    
    func updateAPITypeToNewsAPI() {
        currentAPIType = .newsAPI
    }
    
    func passAPIType() -> APIType {
        return currentAPIType
    }
}
