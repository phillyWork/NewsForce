//
//  NewsRouter.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/23.
//

import Foundation

import Alamofire

enum NewsAPIRouter: URLRequestConvertible {
   
    case newsSearch(query: String, keyIndex: Int, page: Int, sortBy: NewsAPISearchSortType)
    
    private var headers: HTTPHeaders {
        switch self {
        case .newsSearch(query: _, keyIndex: let index, page: _, sortBy: _):
            return [NetworkSetupValues.newsAPIKeyHeader: APIKey.newsAPIAccessKeys[index]]
        }
    }
    
    private var method: HTTPMethod {
        return .get
    }
    
    private var baseURL: URL? {
        switch self {
        case .newsSearch:
            if let url = URL(string: NetworkSetupValues.newsAPIBaseURL) {
                return url
            }
            return nil
        }
    }
    
    private var path: String {
        switch self {
        case .newsSearch:
            return "everything"
        }
    }
    
    private var query: [String: String] {
        switch self {
        case .newsSearch(query: let q, keyIndex: _, page: let page, sortBy: let sortType):
            return ["q": q, "language": NetworkSetupValues.newsAPILanguages, "sortBy": sortType.rawValue, "pageSize": "\(Constant.APISetup.newsAPIPageSize)", "page": "\(page)"]
        }
    }
    
    func asURLRequest() throws -> URLRequest {
    
        guard let url = baseURL?.appendingPathComponent(path) else {
            throw NewsAPINetworkError.sourceDoesNotExist
        }
        
        var request = URLRequest(url: url)
        request.method = method
        request.headers = headers
        
        do {
            request = try URLEncodedFormParameterEncoder(destination: .methodDependent).encode(query, into: request)
            return request
        } catch {
            throw NewsAPINetworkError.parameterInvalid
        }
    }
    
}
