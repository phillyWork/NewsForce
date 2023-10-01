//
//  RealmStruct.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import Foundation
import RealmSwift

final class Journal: Object {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var title: String
    @Persisted var newsDescription: String
    @Persisted var pubDate: String
    @Persisted var link: String
    @Persisted var memo: MemoTable?
    
    convenience init(title: String, newsDescription: String, pubDate: String, link: String) {
        self.init()
        self.title = title
        self.newsDescription = newsDescription
        self.pubDate = pubDate
        self.link = link
    }
}

final class MemoTable: EmbeddedObject {
    
    @Persisted var title: String
    @Persisted var createdAt: Date
    @Persisted var editedAt: Date
    @Persisted var content: String
    @Persisted var tags: TagTable?
}

final class TagTable: EmbeddedObject {
    
    //enum으로 관리
    @Persisted var firstTag: TagType?
    @Persisted var secondTag: TagType?
    @Persisted var thirdTag: TagType?
    
}
