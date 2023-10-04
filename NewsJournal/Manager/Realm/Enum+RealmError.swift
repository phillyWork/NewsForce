//
//  Enum+RealmError.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/03.
//

import Foundation

enum RealmError: Error {
    
    case checkSchemaFailure
    case createObjectFailure
    case updateObjectFailure
    case deleteObjectFailure
    
    var alertTitle: String {
        switch self {
        case .checkSchemaFailure:
            return "DB 업데이트 실패"
        case .createObjectFailure:
            return "저널 생성 실패"
        case .updateObjectFailure:
            return "저널 수정 실패"
        case .deleteObjectFailure:
            return "저널 삭제 실패"
        }
    }
    
    var alertMessage: String {
        switch self {
        case .checkSchemaFailure:
            return "업데이트 된 DB를 가져올 수 없어요. 앱을 다시 실행해주세요."
        case .createObjectFailure:
            return "새로운 저널을 생성할 수 없어요. 다시 시도해주세요."
        case .updateObjectFailure:
            return "저널 수정을 할 수 없어요. 다시 시도해주세요."
        case .deleteObjectFailure:
            return "저널 삭제를 할 수 없어요. 다시 시도해주세요."
        }
    }
}
