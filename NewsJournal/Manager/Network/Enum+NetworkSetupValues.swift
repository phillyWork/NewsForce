//
//  Enum+NetworkSetupValues.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/12.
//

import Foundation

enum NetworkSetupValues {
    
    static let naverCliendtId = "X-Naver-Client-Id"
    static let naverClientSecret = "X-Naver-Client-Secret"
    static let naverApiURL = "https://openapi.naver.com/v1/search/news.json"
    
    static let mediaStackApiBaseURL = "http://api.mediastack.com/v1/"
    static let mediaStackCountries = "us,gb"
    static let mediaStackLanguages = "en"
    static let mediaStackPopularity = "popularity"
    
    static let newsAPIBaseURL = "https://newsapi.org/v2/"
    static let newsAPIKeyHeader = "X-Api-Key"
    static let newsAPILanguages = "en"
    static let newsAPIPageSize = 50
}
