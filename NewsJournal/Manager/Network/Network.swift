//
//  Network.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import Foundation

import Alamofire

final class Network {
    
    static let shared = Network()
    private init() { }
    
    func naverCallRequest<T: Decodable>(type: T.Type, api: NaverRouter, completionHandler: @escaping (Result<T, NaverNetworkError>) -> Void ) {
        AF.request(api).responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let value):
                completionHandler(.success(value))
            case .failure(_):
                let statusCode = response.response?.statusCode ?? 500
                guard let error = NaverNetworkError(rawValue: statusCode) else { return }
                completionHandler(.failure(error))
            }
        }
    }
    
    func mediaStackCallRequest<T: Decodable>(type: T.Type, api: MediaStackRouter, completionHandler: @escaping (Result<T, MediaStackNetworkError>) -> Void ) {
        print(#function)
        AF.request(api).responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let value):
                completionHandler(.success(value))
            case .failure(let failure):
                if let error = failure.underlyingError as? MediaStackNetworkError {
                    completionHandler(.failure(error))
                }
            }
        }
    }
    
    func newsAPICallRequest<T: Decodable>(type: T.Type, api: NewsAPIRouter, completionHandler: @escaping (Result<T, NewsAPINetworkError>) -> Void ) {
        AF.request(api).responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let value):
                completionHandler(.success(value))
            case .failure(let failure):
                if let error = failure.underlyingError as? NewsAPINetworkError {
                    completionHandler(.failure(error))
                }
            }
        }
    }
        
}
