//
//  Enum+LPError.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/01.
//

import Foundation
import LinkPresentation

extension LPError {
    
    //toast 메시지로 나타내기?
    
    var alertTitle: String {
        switch self.code {
        case .metadataFetchCancelled:
            //return "Meta Data Fetch Cancelled"
            return "접근 거부"
        case .metadataFetchFailed:
//            return "Meta Data Fetch Failed"
            return "요청 실패"
        case .metadataFetchTimedOut:
            //return "Meta Data Fetch Time Out"
            return "요청 시간 초과!"
        case .unknown:
//            return "Meta Data Fetch Unknown Error"
            return "원인 불명 실패"
        @unknown default:
//            return "Meta Data Fetch Unknown Error"
            return "원인 불명 실패"
        }
    }
    
    var alertMessage: String {
        switch self.code {
        case .metadataFetchCancelled:
//            return "Meta Data Fetch Cancelled by client"
            return "클라이언트에 의해 링크 접근이 불가능합니다."
        case .metadataFetchFailed:
//            return "Meta Data Fetch Failed"
            return "링크 접근이 불가능합니다."
        case .metadataFetchTimedOut:
//            return "Meta Data Fetch TimeOut: Took longer than allowed timer"
            return "요청 시간이 초과되어 실패했습니다. 잠시 후 다시 시도해주세요."
        case .unknown:
//            return "Meta Data Fetch Unknown Error"
            return "알 수 없는 원인으로 실패했습니다. 잠시 후 다시 시도해주세요."
        @unknown default:
//            return "Meta Data Fetch Unknown Error"
            return "알 수 없는 원인으로 실패했습니다. 잠시 후 다시 시도해주세요."
        }
        
    }
    
}
