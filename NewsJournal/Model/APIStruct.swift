//
//  APIStruct.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import Foundation

// MARK: - NewsTotal
struct NewsTotal: Codable, Hashable {
    let lastBuildDate: String
    let total, start, display: Int
    let items: [News]
}

// MARK: - Item
struct News: Codable, Hashable {
    let title: String
    let originallink: String
    let link: String
    let description, pubDate: String
    
    //Hashable, UserDefaults
    let id = UUID().uuidString
    
    var existingLink: String {
        return originallink.isEmpty ? link : originallink
    }
}
