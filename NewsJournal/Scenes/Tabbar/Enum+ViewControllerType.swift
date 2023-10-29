//
//  Enum+ViewControllerType.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/01.
//

import Foundation

enum ViewControllerType {
    
    case defaultNewsAsHome
    case newsSearchWithRecentWords
    case journalWithPinnedNews
    
    var navBarTitle: String {
        switch self {
        case .defaultNewsAsHome:
            return "오늘의 기사"
        case .newsSearchWithRecentWords:
            return "검색"
        case .journalWithPinnedNews:
            return "북마크 & 저널"
        }
    }
    
    var tabbarTitle: String {
        switch self {
        case .defaultNewsAsHome:
            return "오늘의 기사"
        case .newsSearchWithRecentWords:
            return "기사 검색"
        case .journalWithPinnedNews:
            return "저널 목록"
        }
    }
    
    var tabbarItemString: String {
        switch self {
        case .defaultNewsAsHome:
            return Constant.ImageString.homeImageString
        case .newsSearchWithRecentWords:
            return Constant.ImageString.searchMagnifyingGlassImageString
        case .journalWithPinnedNews:
            return Constant.ImageString.listImageString
        }
    }
    
    var searchBarPlaceholder: String {
        switch self {
        case .defaultNewsAsHome:
            return "홈화면입니다"
        case .newsSearchWithRecentWords:
            return "새로운 기사를 검색해보세요"
        case .journalWithPinnedNews:
            return "저장한 저널을 검색해보세요"
        }
    }
    
}
