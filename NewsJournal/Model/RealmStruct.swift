//
//  RealmStruct.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import Foundation
import RealmSwift

// DTO --> entity로 레이어화 (data 및 schema update 고려)

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
    @Persisted var firstTag: TagType
    @Persisted var secondTag: TagType
    @Persisted var thirdTag: TagType
 
    func returnTagsInString() -> String {
        var result = PDFCreatorSetupValues.basicTag
        
        if firstTag != .none {
            result += "#\(firstTag.rawValue) "
        }
        if secondTag != .none, secondTag != firstTag {
            result += "#\(secondTag.rawValue) "
        }
        if thirdTag != .none, thirdTag != firstTag, thirdTag != secondTag {
            result += "#\(thirdTag.rawValue) "
        }
        
        return result
    }
    
}
