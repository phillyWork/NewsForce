//
//  APIStruct.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import Foundation

// MARK: - NewsTotal
struct NaverNewsTotal: Codable {
    let lastBuildDate: String
    let total, start, display: Int
    let items: [NaverNews]
}

// MARK: - Item
struct NaverNews: Codable {
    let title: String
    let originallink: String
    let link: String
    let description, pubDate: String
    
    var existingLink: String {
        return originallink.isEmpty ? link : originallink
    }
    
    var pubDateInFormat: String {
        if let date = pubDate.toDateWithNaverType() {
            return date.toString()
        }
        return pubDate
    }
    
    var htmlReducedTitle: String {
        let result = title.htmlAttributedString(value: title)
        return result
    }
    
    var htmlReducedDescription: String {
        let result = description.htmlAttributedString(value: description)
        return result
    }
    
    var pubDateInNameFormat: String {
        if let date = pubDate.toDateWithNaverType() {
            return date.toStringForImageNameURL()
        }
        return pubDate
    }
    
    var nameForURL: String {
        let noSlash = existingLink.replacingOccurrences(of: "/{1,}", with: "", options: .regularExpression)
        let noColon = noSlash.replacingOccurrences(of: ":", with: "_")
        return noColon + pubDateInNameFormat
    }
    
    
    func createDTONews() -> DTONews {
        return DTONews(title: htmlReducedTitle, urlLink: existingLink, description: htmlReducedDescription, pubDate: pubDateInFormat, imageURL: nil)
    }
    
}
