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
    
    var news: News?
    var objectId: ObjectId?
    
    var webErrorMessage = Observable("")
    
    private var vcType: ViewControllerType = .newsSearchVC
    
    private let repository = Repository.shared
    
    //MARK: - API
    
    func retrieveLinkFromPassedData() throws -> String {
        switch vcType {
        case .newsSearchVC:
            guard let news = news else { throw WebViewError.noNewsToRetrieve }
            //from newsVC: webview load with news link
            return news.existingLink
        case .journalVC:
            guard let id = objectId else { throw WebViewError.noJournalToRetrieve }
            //check webView load & show saved memo
            do {
                let journal = try retrieveJournal(id)
                return journal.link
            } catch WebViewError.noJournalToRetrieve {
                //no memo to retrieve from realm
                throw WebViewError.noJournalToRetrieve
            }
        }
    }
    
    func retrieveJournal(_ objectId: ObjectId) throws -> Journal {
        if let journal = repository.fetchSingleRecord(objectId: objectId) {
            return journal
        } else {
            throw WebViewError.noJournalToRetrieve
        }
    }
    
    func returnCurrentType() -> ViewControllerType {
        return vcType
    }
    
    func updateCurrentVCType(newType: ViewControllerType) {
        vcType = newType
    }
    
}
