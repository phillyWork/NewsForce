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
    
    private var headers: HTTPHeaders {
        switch self {
        case .naverNewsSearch:
            return [NetworkSetupValues.naverCliendtId: APIKey.naverClientID,
                    NetworkSetupValues.naverClientSecret: APIKey.naverClientSecret]
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
        }
    }
    
    private var query: [String: String] {
        switch self {
        case .naverNewsSearch(let query, let start, let sort):
            return ["query": query, "display": "\(Constant.APISetup.naverDisplay)", "start": "\(start)", "sort": sort.rawValue]
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        
        guard let url = baseURL else {
            throw NaverNetworkError.invalidSearchAPI
        }
        
        var request = URLRequest(url: url)
        request.headers = headers
        request.method = method
        do {
            request = try URLEncodedFormParameterEncoder(destination: .methodDependent).encode(query, into: request)
            return request
        } catch {
            throw NaverNetworkError.httpMethodNotAllowed
        }
    }
    
}
