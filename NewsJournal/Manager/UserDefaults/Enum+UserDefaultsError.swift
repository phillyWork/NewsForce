//
//  Enum+UserDefaultsError.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/05.
//

import Foundation

enum UserDefaultsError: Error {
    
    case cannotDecodeData
    case noDataInUserDefault
    case cannotSaveTempMemoForNews
    case cannotSaveTempMemoForJournal
    case cannotSaveTempTitleForNews
    case cannotSaveTempTitleForJournal
    
}
