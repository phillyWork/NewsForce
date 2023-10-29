//
//  Enum+TagType.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/01.
//

import Foundation

import RealmSwift

enum TagType: String, PersistableEnum {
    
    case whole = "전체"
    case politics = "정치"
    case economy = "경제"
    case art = "예술"
    case entertainment = "연예"
    case science = "과학"
    case technology = "기술"
    case health = "건강"
    case lifestyle = "라이프"
    case sports = "스포츠"
    case world = "글로벌"
    case none = "---"
    
}
