//
//  RealmStruct.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import Foundation
import RealmSwift

// DTO --> entity로 레이어화 (data 및 schema update 고려)

final class BookMarkedNews: Object {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var apiType: APIType
    @Persisted var title: String
    @Persisted var newsDescription: String
    @Persisted var pubDate: String
    @Persisted var link: String
    @Persisted var journal: Journal?
    
    convenience init(title: String, newsDescription: String, pubDate: String, link: String, apiType: APIType) {
        self.init()
        self.title = title
        self.newsDescription = newsDescription
        self.pubDate = pubDate
        self.link = link
        self.apiType = apiType
    }
    
    var nameForURL: String {
        let noSlash = link.replacingOccurrences(of: "/{1,}", with: "", options: .regularExpression)
        let noColon = noSlash.replacingOccurrences(of: ":", with: "_")
        return noColon + pubDate
    }
    
}

final class Journal: EmbeddedObject {
    
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
