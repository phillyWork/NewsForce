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
    
    func callRequest<T: Decodable>(type: T.Type, api: Router, completionHandler: @escaping (Result<T, NetworkError>) -> Void ) {
        AF.request(api).responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let value):
                completionHandler(.success(value))
            case .failure(_):
                let statusCode = response.response?.statusCode ?? 500
                guard let error = NetworkError(rawValue: statusCode) else { return }
                completionHandler(.failure(error))
            }
        }
    }
    
}
