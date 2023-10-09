//
//  MemoViewModel.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import Foundation
import RealmSwift

final class MemoViewModel {
    
    //MARK: - Properties
    
    var news: News?
    var objectId: ObjectId?
    
    var memoTableToBeSaved: Observable<MemoTable?> = Observable(nil)
    var tagTableToBeSaved: Observable<TagTable?> = Observable(nil)
    
    var isJournalMade = Observable(false)
    
    var firstTag = TagType.none
    var secondTag = TagType.none
    var thirdTag = TagType.none
    
    var memoErrorMessage: Observable<String> = Observable("")
    
    private let userDefault = UserDefaultsManager.shared
    private let repository = Repository.shared
    
    
    //MARK: - UserDefault API
    
    func retrieveTempTitleFromUserDefaults() throws -> String {
        if let id = objectId, let journal = repository.fetchSingleRecord(objectId: id) {
            do {
                let tempTitle = try userDefault.retrieveFromUserDefaults(forKey: journal.title) as String
                return tempTitle
            } catch {
                throw MemoError.noTempTitleForJournal
            }
        } else {
            guard let news = news else { throw MemoError.noNewsToRetrieve }
            do {
                let tempTitle = try userDefault.retrieveFromUserDefaults(forKey: news.title) as String
                return tempTitle
            } catch {
                throw MemoError.noTempTitleForNews
            }
        }
    }
    
    func retrieveTempMemoFromUserDefaults() throws -> String {
        if let id = objectId {
            //from Journal
            do {
                let tempMemo = try userDefault.retrieveFromUserDefaults(forKey: "\(id)") as String
                return tempMemo
            } catch {
                //userDefault의 memo 존재하지 않음
                //object의 memo로 설정하기
                throw MemoError.noTempMemoForJournal
            }
        } else {
            //from News
            guard let news = news else { throw MemoError.noNewsToRetrieve }
            do {
                let tempMemo = try userDefault.retrieveFromUserDefaults(forKey: news.id) as String
                return tempMemo
            } catch {
                //userDefault의 memo 존재하지 않음
                //placeholder 설정 알리기
                throw MemoError.noTempMemoForNews
            }
        }
    }
    
    func saveTempTitleToUserDefaults(_ title: String) throws {
        if let id = objectId, let journal = repository.fetchSingleRecord(objectId: id) {
            if !userDefault.saveToUserDefaults(newValue: title, forKey: journal.title ) {
                throw UserDefaultsError.cannotSaveTempTitleForJournal
            }
        } else {
            guard let news = news else { return }
            if !userDefault.saveToUserDefaults(newValue: title, forKey: news.title) {
                throw UserDefaultsError.cannotSaveTempTitleForNews
            }
        }
    }
    
    func saveTempMemoToUserDefaults(_ text: String) throws {
        if let id = objectId {
            //from Journal
            if !userDefault.saveToUserDefaults(newValue: text, forKey: "\(id)") {
                //수정 임시 메모 저장 실패 알림
                throw UserDefaultsError.cannotSaveTempMemoForJournal
            }
        } else {
            //from News
            guard let news = news else { return }
            if !userDefault.saveToUserDefaults(newValue: text, forKey: news.id) {
                //임시 메모 저장 실패 알림
                throw UserDefaultsError.cannotSaveTempMemoForNews
            }
        }
    }
    
    //MARK: - Realm API
    
    func checkRealmSchemaAndPath() {
        do {
            try repository.checkSchemaVersion()
        } catch {
            memoErrorMessage.value = RealmError.checkSchemaFailure.alertMessage
        }
    }
    
    func retrieveMemoTitle() throws -> String {
        if let id = objectId, let journal = repository.fetchSingleRecord(objectId: id) {
            if let memo = journal.memo {
                return memo.title
            } else {
                throw MemoError.noMemoToRetrieve
            }
        } else {
            throw MemoError.noJournalToRetrieve
        }
    }
    
    func retrieveMemoContent() throws -> String {
        if let id = objectId, let journal = repository.fetchSingleRecord(objectId: id) {
            if let memo = journal.memo {
                return memo.content
            } else {
                throw MemoError.noMemoToRetrieve
            }
        } else {
            throw MemoError.noJournalToRetrieve
        }
    }
    
    func handleMemo(title: String, content: String) throws {
        
        let newMemo = MemoTable()
        newMemo.title = title
        newMemo.content = removeMultipleNewLinesInContent(content: content)
        newMemo.editedAt = Date()
        
        if let objectId = objectId {
            //기존 메모 수정
            guard let journal = repository.fetchSingleRecord(objectId: objectId) else { throw MemoError.noJournalToRetrieve }
            guard let existingMemo = journal.memo else { throw MemoError.noMemoToRetrieve }
            newMemo.createdAt = existingMemo.createdAt
            memoTableToBeSaved.value = newMemo
        } else {
            //새로운 메모 생성
            newMemo.createdAt = Date()
            memoTableToBeSaved.value = newMemo
        }
    }
    
    //save 할 때: 빈칸 미리 제거하기
    private func removeMultipleNewLinesInContent(content: String) -> String {
        //첫 줄 엔터 제거
        let eraseFirstNewLineContent = content.replacingOccurrences(of: MemoSetupValues.firstLineNewLine, with: MemoSetupValues.replaceInBlank, options: .regularExpression)
        //네 줄 이상의 엔터 제거 (최대 3개까지 허용)
        let eraseMultipleNewLinesContent = eraseFirstNewLineContent.replacingOccurrences(of: MemoSetupValues.multipleNewLinesMoreThanThree, with: MemoSetupValues.replaceInThreeNewLines, options: .regularExpression)
        return eraseMultipleNewLinesContent
    }
    
    func handleTag() {
        
        //create new tags to be added or updated
        let newTag = TagTable()
        newTag.firstTag = firstTag
        newTag.secondTag = secondTag
        newTag.thirdTag = thirdTag
        
        tagTableToBeSaved.value = newTag
    }
    
    func saveJournalToRealm() {
        
        memoTableToBeSaved.value?.tags = tagTableToBeSaved.value
        
        //최종 저장하기
        if let id = objectId {
            //기존 저널 수정하기
            guard let object = repository.fetchSingleRecord(objectId: id) else {
                //해당 저널 존재하지 않음: alert or toast message
                memoErrorMessage.value = MemoError.noJournalToRetrieve.alertMessage
                return
            }
            
            guard let newMemo = memoTableToBeSaved.value else { return }
            
            //업데이트 하려고 준비한 메모 및 태그로 저장하기
            do {
                try repository.updateRecordOfMemo(record: object, newMemo: newMemo)
                //성공 toast 메시지 띄우기?
                
                
                //remove from UserDefaults: 실패를 굳이 알려야 하는지 의문...
                if userDefault.deleteFromUserDefaults(type: String.self, forKey: object.title) {
                    if userDefault.deleteFromUserDefaults(type: String.self, forKey: "\(id)") {
                        isJournalMade.value = true
                    } else {
                        //임시 memo 삭제 실패 toast
                        memoErrorMessage.value = MemoSetupValues.deletionTempMemoFailed
                        isJournalMade.value = true
                    }
                } else {
                    //임시 title 삭제 실패 toast
                    memoErrorMessage.value = MemoSetupValues.deletionTempTitleFailed
                }
            } catch {
                //수정 실패: toast 띄우기
                memoErrorMessage.value = MemoSetupValues.updatingJournalFailed
                isJournalMade.value = false
            }
        } else {
            guard let news = news else { return }
            
            let newJournal = Journal(title: news.htmlReducedTitle, newsDescription: news.htmlReducedDescription, pubDate: news.pubDate, link: news.existingLink)
            
            newJournal.memo = memoTableToBeSaved.value
            
            do {
                try repository.createRecord(record: newJournal)
                //저장 완료 toast 띄우기?
                
                
                //remove from UserDefaults: 실패를 굳이 알려야 하는지 의문...
                if userDefault.deleteFromUserDefaults(type: String.self, forKey: news.title) {
                    if userDefault.deleteFromUserDefaults(type: String.self, forKey: news.id) {
                        isJournalMade.value = true
                    } else {
                        //임시 memo 제거 에러 toast 띄우기
                        memoErrorMessage.value = MemoSetupValues.deletionTempMemoFailed
                        isJournalMade.value = true
                    }
                } else {
                    //임시 title 제거 에러 toast 띄우기
                    memoErrorMessage.value = MemoSetupValues.deletionTempTitleFailed
                    isJournalMade.value = true
                }
            } catch {
                //저장 실패: toast 띄우기
                memoErrorMessage.value = MemoSetupValues.savingNewCreatedJournalFailed
                isJournalMade.value = false
            }
        }
        
    }

}
