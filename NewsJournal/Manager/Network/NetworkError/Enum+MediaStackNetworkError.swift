//
//  Enum+MediaStackNetworkError.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/14.
//

import Foundation

enum MediaStackNetworkError: String, Error, LocalizedError {
    
    case invalid_access_key
    case missing_access_key
    case inactive_user
    case https_access_restricted
    case function_access_restricted
    case invalid_api_function
    case not_found
    case usage_limit_reached
    case rate_limit_reached
    case internal_error
    
    var errorDescription: String {
        switch self {
        case .invalid_access_key:
            return "An invalid API access key was supplied."
        case .missing_access_key:
            return "No API access key was supplied."
        case .inactive_user:
            return "The given user account is inactive."
        case .https_access_restricted:
            return "HTTPS access is not supported on the current subscription plan."
        case .function_access_restricted:
            return "The given API endpoint is not supported on the current subscription plan."
        case .invalid_api_function:
            return "The given API endpoint does not exist."
        case .not_found:
            return "Resource not found."
        case .usage_limit_reached:
            return "The given user account has reached its monthly allowed request volume."
        case .rate_limit_reached:
            return "The given user account has reached the rate limit."
        case .internal_error:
            return "An internal error occurred."
        }
    }
}
