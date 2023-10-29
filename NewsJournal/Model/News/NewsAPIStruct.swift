//
//  NewsAPIStruct.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/23.
//

import Foundation

// MARK: - NewsAPI
struct NewsAPITotal: Codable {
    let status: String
    let totalResults: Int?
    let articles: [Article]?
    let code: String?
    let message: String?
}

// MARK: - Article
struct Article: Codable {
    let source: Source
    let author: String?
    let title, description: String
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String
    
    var pubDateInFormat: String {
        if let date = publishedAt.toDateWithMediaStackAndNewsAPI() {
            return date.toString()
        }
        return publishedAt
    }
    
    func createDTO() -> DTONews {
        return DTONews(title: title, urlLink: url, description: description, pubDate: pubDateInFormat, imageURL: urlToImage)
    }
}

// MARK: - Source
struct Source: Codable {
    let id: String?
    let name: String
}
