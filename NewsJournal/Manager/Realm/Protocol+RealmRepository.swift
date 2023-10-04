//
//  Protocol+RealmRepository.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/03.
//

import Foundation
import RealmSwift

protocol RealmRepositoryProtocol {
    
    func checkSchemaVersion() throws
    func fetch<T:Object>(type: T.Type) -> Results<T>?
    func updateItem(task: [String: Any]) throws
    func createItem<T:Object>(record: T) throws
    func deleteItem<T:Object>(record: T) throws
    
}
