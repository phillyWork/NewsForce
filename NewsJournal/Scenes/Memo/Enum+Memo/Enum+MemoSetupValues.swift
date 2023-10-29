//
//  Enum+MemoSetupValues.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/05.
//

import Foundation

enum MemoSetupValues {
    
    static let textViewPlaceholders = ["기사를 읽고 어떤 생각이 떠오르시나요?", "당신의 논지를 작성해보세요", "저널을 입력해주세요"]
    static let textFieldPlaceholder = "제목을 입력해주세요"
    static let firstLineNewLine = "^\n"
    static let replaceInBlank = ""
    static let multipleNewLinesMoreThanThree = "\n{4,}"
    static let replaceInThreeNewLines = "\n\n\n"
    
    static let journalCannotBeSavedDueToNoContent = "입력이 있어야 저장할 수 있어요"
    
    static let noTempTitle = "임시 저장된 제목이 없어요"
    static let noTempMemo = "임시 저장된 저널이 없어요"
    
    static let savingTempTitleFailed = "제목을 임시 저장할 수 없어요"
    static let savingTempMemoFailed = "저널을 임시 저장할 수 없어요"
    
    static let deletionTempTitleFailed = "임시 제목을 삭제할 수 없어요"
    static let deletionTempMemoFailed = "임시 저널을 삭제할 수 없어요"
    
    static let updatingJournalFailed = "수정에 실패했어요. 다시 시도해주세요"
    static let savingNewlyCreatedJournalFailed = "저장에 실패했어요. 다시 시도해주세요"
    
    static let savingNewlyCreatedJournalSucceed = "저장 성공!"
    static let updatingJournalSucceed = "수정 성공!"
    
}
