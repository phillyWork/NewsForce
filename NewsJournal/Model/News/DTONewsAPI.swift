//
//  DTONewsAPI.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/14.
//

import Foundation

struct DTONews: Codable, Hashable {
    
    let title: String
    let urlLink: String
    let description: String
    let pubDate: String
    let imageURL: String?
    
    //Hashable, UserDefaults
    let id = UUID().uuidString
    
    var pubDateInNameFormat: String {
        if let date = pubDate.toDateWithNaverType() {
            return date.toStringForImageNameURL()
        }
        return pubDate
    }
    
    var nameForURL: String {
        let noSlash = urlLink.replacingOccurrences(of: "/{1,}", with: "", options: .regularExpression)
        let noColon = noSlash.replacingOccurrences(of: ":", with: "_")
        return noColon + pubDateInNameFormat
    }
    
}
