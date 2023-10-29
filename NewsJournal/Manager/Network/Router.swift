//
//  Router.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import Foundation
import Alamofire

enum NaverRouter: URLRequestConvertible {
   
    case naverNewsSearch(query: String, start: Int, sort: NaverNewsSearchSortType)
    case mediaStackSearch(query: String, offset: Int, sort: MediaStackNewsSearchSortType, keyIndex: Int)
    case mediaStackDefaultLiveNews(today: Date, offset: Int, keyIndex: Int)
    
    private var headers: HTTPHeaders {
        switch self {
        case .naverNewsSearch:
            return [NetworkSetupValues.naverCliendtId: APIKey.naverClientID,
                    NetworkSetupValues.naverClientSecret: APIKey.naverClientSecret]
        case .mediaStackSearch, .mediaStackDefaultLiveNews:
            return ["":""]
        }
    }
    
    private var method: HTTPMethod {
        return .get
    }
    
    private var baseURL: URL? {
        switch self {
        case .naverNewsSearch:
            if let url = URL(string: NetworkSetupValues.naverApiURL) {
                return url
            }
            return nil

        case .mediaStackSearch, .mediaStackDefaultLiveNews:
            if let url = URL(string: NetworkSetupValues.mediaStackApiBaseURL) {
                return url
            }
            return nil
        }
    }
    
    private var path: String {
        switch self {
        case .naverNewsSearch:
            return ""
        case .mediaStackSearch:
            return "sources"
        case .mediaStackDefaultLiveNews:
            return "news"
        }
    }
    
    private var query: [String: String] {
        switch self {
        case .naverNewsSearch(let query, let start, let sort):
            return ["query": query, "display": "\(Constant.APISetup.naverDisplay)", "start": "\(start)", "sort": sort.rawValue]
        case .mediaStackSearch(query: let query, offset: let offset, sort: let sort, keyIndex: let index):
            return ["access_key": APIKey.mediaStackAccessKeys[index], "search": query, "countries": NetworkSetupValues.mediaStackCountries, "languages": NetworkSetupValues.mediaStackLanguages, "offset": "\(offset)", "limit": "\(Constant.APISetup.mediaStackLimit)", "sort": sort.rawValue]
        case .mediaStackDefaultLiveNews(today: let today, offset: let offset, keyIndex: let index):
            return ["access_key": APIKey.mediaStackAccessKeys[index], "countries": NetworkSetupValues.mediaStackCountries, "languages": NetworkSetupValues.mediaStackLanguages, "date": today.toStringForDefaultNews(), "sort": MediaStackNewsSearchSortType.popularity.rawValue, "offset": "\(offset)", "limit": "\(Constant.APISetup.mediaStackLimit)"]
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        
        
        
        guard let url = baseURL?.appendingPathComponent(path) else {
            throw NaverNetworkError.invalidSearchAPI
        }
        
        var request = URLRequest(url: url)
        request.headers = headers
        request.method = method
        do {
            request = try URLEncodedFormParameterEncoder(destination: .methodDependent).encode(query, into: request)
            return request
        } catch {
            throw
        }
    }
    
}
