//
//  Router.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
   
    case newsSearch(query: String, start: Int, sort: SortType)
    
    private var headers: HTTPHeaders {
        ["X-Naver-Client-Id": APIKey.clientID,
         "X-Naver-Client-Secret": APIKey.clientSecret]
    }
    
    private var method: HTTPMethod {
        return .get
    }
    
    private var baseURL: URL? {
        if let url = URL(string: "https://openapi.naver.com/v1/search/news.json") {
            return url
        }
        return nil
    }
    
//    private var path: String {
//
//    }
    
    private var query: [String: String] {
        switch self {
        case .newsSearch(let query, let start, let sort):
            return ["query": query, "display": "\(Constant.APISetup.display)", "start": "\(start)", "sort": "\(sort.rawValue)"]
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        if let url = baseURL {
            var request = URLRequest(url: url)
            request.headers = headers
            request.method = method
            request = try URLEncodedFormParameterEncoder(destination: .methodDependent).encode(query, into: request)
            return request
        } else {
            throw NetworkError.invalidSearchAPI
        }
    }
    
}
