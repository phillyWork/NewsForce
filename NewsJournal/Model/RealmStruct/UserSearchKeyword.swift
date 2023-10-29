//
//  UserSearchKeywords.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/13.
//

import Foundation

import RealmSwift

final class UserSearchKeyword: Object {
    
    @Persisted(primaryKey: true) var searchWord: String
    @Persisted var searchWordCount: Int
    @Persisted var lastlySearchedAt: Date

    convenience init(searchWord: String, lastlySearchedAt: Date) {
        self.init()
        self.searchWord = searchWord
        self.searchWordCount = 1
        self.lastlySearchedAt = lastlySearchedAt
    }
    
}
