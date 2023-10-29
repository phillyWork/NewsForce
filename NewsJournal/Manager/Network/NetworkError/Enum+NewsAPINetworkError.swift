//
//  Enum+NewsAPINetworkError.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/23.
//

import Foundation

enum NewsAPINetworkError: String, Error, LocalizedError {

    case apiKeyDisabled
    case apiKeyExhausted
    case apiKeyInvalid
    case apiKeyMissing
    case parameterInvalid
    case parametersMissing
    case rateLimited
    case sourcesTooMany
    case sourceDoesNotExist
    case unexpectedError
    
    var alertMessage: String {
        switch self {
        case .apiKeyDisabled:
            //Your API key has been disabled.
            return "유효하지 않은 키에요. 다시 시도해주세요."
        case .apiKeyExhausted:
            //Your API key has no more requests available.
            return "오늘 검색할 수 있는 한도를 초과했어요. 내일 다시 이용해주세요."
        case .apiKeyInvalid:
            //Your API key hasn't been entered correctly. Double check it and try again.
            return "키가 일치하지 않아요. 다시 시도해주세요."
        case .apiKeyMissing:
            //Your API key is missing from the request. Append it to the request with one of these methods.
            return "키가 누락되었어요. 다시 시도해주세요."
        case .parameterInvalid:
            //You've included a parameter in your request which is currently not supported. Check the message property for more details.
            return "유효하지 않은 검색이에요. 다시 시도해주세요."
        case .parametersMissing:
            //Required parameters are missing from the request and it cannot be completed. Check the message property for more details.
            return "검색어가 누락되었어요. 다시 시도해주세요."
        case .rateLimited:
            //You have been rate limited. Back off for a while before trying the request again.
            return "검색 과정에서 오류가 발생했어요. 잠시 후 다시 시도해주세요."
        case .sourcesTooMany:
            //You have requested too many sources in a single request. Try splitting the request into 2 smaller requests.
            return "해당 검색을 시도할 수 없어오. 다시 시도해주세요."
        case .sourceDoesNotExist:
            //You have requested a source which does not exist.
            return "해당 검색은 현재 불가능해요. 다시 시도해주세요."
        case .unexpectedError:
            //This shouldn't happen, and if it does then it's our fault, not yours. Try the request again shortly.
            return "알 수 없는 에러가 발생했어요. 잠시 후 다시 시도해주세요."
        }
    }
    
}
