//
//  NewsAPIStruct.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/13.
//

import Foundation

// MARK: - MediaStackNews
struct MediaStackNewsTotal: Codable {
    let pagination: Pagination
    let data: [MediaStackNews]
}

// MARK: - Pagination
struct Pagination: Codable, Hashable {
    let limit, offset, count, total: Int
}

// MARK: - Datum
struct MediaStackNews: Codable {
        
    let author: String?
    let title, description: String
    let url: String
    let source: String
    let image: String?
    let category: String
    let language: String
    let country: String
    let publishedAt: String

    enum CodingKeys: String, CodingKey {
        case author, title, description, url, source, image, category, language, country
        case publishedAt = "published_at"
    }
    
    var pubDateInFormat: String {
        if let date = publishedAt.toDateWithMediaStackAndNewsAPI() {
            return date.toString()
        }
        return publishedAt
    }
    
    var nameForURL: String {
        let noSlash = url.replacingOccurrences(of: "/{1,}", with: "")
        let noColon = noSlash.replacingOccurrences(of: ":", with: "_")
        return noColon + pubDateInFormat
    }
    
    func createDTONews() -> DTONews {
        return DTONews(title: title, urlLink: url, description: description, pubDate: pubDateInFormat, imageURL: image)
    }
    
}
