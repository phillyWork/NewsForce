//
//  Enum+MemoSetupValues.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/05.
//

import Foundation

enum MemoSetupValues {
    
    static let textViewPlaceholder = "메모를 입력해주세요"
    static let textFieldPlaceholder = "제목을 입력해주세요"
    static let firstLineNewLine = "^\n"
    static let replaceInBlank = ""
    static let multipleNewLinesMoreThanThree = "\n{4,}"
    static let replaceInThreeNewLines = "\n\n\n"
    
    static let noTempTitle = "임시 저장된 제목이 없어요"
    static let noTempMemo = "임시 저장된 메모가 없어요"
    
    static let savingTempTitleFailed = "제목을 임시 저장할 수 없어요"
    static let savingTempMemoFailed = "메모를 임시 저장할 수 없어요"
    
    static let deletionTempTitleFailed = "임시 제목을 삭제할 수 없어요"
    static let deletionTempMemoFailed = "임시 메모를 삭제할 수 없어요"
    
    static let updatingJournalFailed = "수정에 실패했어요. 다시 시도해주세요"
    static let savingNewlyCreatedJournalFailed = "저장에 실패했어요. 다시 시도해주세요"
    
    static let savingNewlyCreatedJournalSucceed = "저장 성공!"
    static let updatingJournalSuceed = "수정 성공!"
    
}
