//
//  MediaStackRouter.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/14.
//

import Foundation

import Alamofire

enum MediaStackRouter: URLRequestConvertible {
   
    case mediaStackDefaultLiveNews(today: Date, offset: Int, keyIndex: Int)
    
    private var method: HTTPMethod {
        return .get
    }
    
    private var baseURL: URL? {
        switch self {
        case .mediaStackDefaultLiveNews:
            if let url = URL(string: NetworkSetupValues.mediaStackApiBaseURL) {
                return url
            }
            return nil
        }
    }
    
    private var path: String {
        switch self {
        case .mediaStackDefaultLiveNews:
            return "news"
        }
    }
    
    private var query: [String: String] {
        switch self {
        case .mediaStackDefaultLiveNews(today: let today, offset: let offset, keyIndex: let index):
            return ["access_key": APIKey.mediaStackAccessKeys[index], "countries": NetworkSetupValues.mediaStackCountries, "languages": NetworkSetupValues.mediaStackLanguages, "date": today.toStringForDefaultNewsForMediaStack(), "sort": NetworkSetupValues.mediaStackPopularity, "offset": "\(offset)", "limit": "\(Constant.APISetup.mediaStackLimit)"]
        }
    }
    
    func asURLRequest() throws -> URLRequest {
    
        guard let url = baseURL?.appendingPathComponent(path) else {
            throw MediaStackNetworkError.invalid_api_function
        }
        
        var request = URLRequest(url: url)
        request.method = method
        
        do {
            request = try URLEncodedFormParameterEncoder(destination: .methodDependent).encode(query, into: request)
            return request
        } catch {
            throw MediaStackNetworkError.https_access_restricted
        }
    }
    
}
