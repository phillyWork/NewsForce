//
//  Enum+NetworkError.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/02.
//

import Foundation

enum NetworkError: Int, Error, LocalizedError {
    
    case invalidQueryParameters = 400
    case authorizationFailure = 401
    case serverRequestForbidden = 403
    case invalidSearchAPI = 404
    case httpMethodNotAllowed = 405
    case totalAPICallExceeded = 429
    case systemError = 500
    
    var errorDescription: String {
        switch self {
        case .invalidQueryParameters:
            return "잘못된 검색이에요. 다시 검색해주세요."
        case .authorizationFailure:
            return "인증 정보가 없어요."
        case .serverRequestForbidden:
            return "서버 접근 권한이 없어요."
        case .invalidSearchAPI:
            return "잘못된 url이에요. 다시 이용해주세요."
        case .httpMethodNotAllowed:
            return "잘못된 http 요청이에요."
        case .totalAPICallExceeded:
            return "하루 검색 요청 횟수를 초과했어요. 내일 다시 이용해주세요."
        case .systemError:
            return "서버 점검 중이에요. 잠시 후 다시 이용해주세요."
        }
    }
    
}
