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
    
    var news: DTONews?
    var objectId: ObjectId?
    
    var journalTableToBeSaved: Observable<Journal?> = Observable(nil)
    var tagTableToBeSaved: Observable<TagTable?> = Observable(nil)
    
    var isJournalMadeFromNaver = Observable(false)
    var isJournalMadeFromMediaStack = Observable(false)
    var isJournalMadeFromNewsAPI = Observable(false)
    
    var firstTag = TagType.none
    var secondTag = TagType.none
    var thirdTag = TagType.none
    
    var memoErrorMessage: Observable<String> = Observable("")
    var memoSuccessMessage: Observable<String> = Observable("")
    
    private var currentApiType: APIType = .naver
    private var bookmarkedNewsLinkForNotification = ""
    
    private let userDefault = UserDefaultsManager.shared
    private let repository = Repository.shared
    
    //MARK: - UserDefault API
    
    func retrieveTempTitleFromUserDefaults() throws -> String {
        if let id = objectId, let journal = repository.fetchSingleRecord(objectId: id) {
            do {
                let tempTitle = try userDefault.retrieveFromUserDefaults(forKey: journal.title) as String
                return tempTitle
            } catch {
                throw MemoError.noTempTitleForBookMarkedNews
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
                throw MemoError.noTempJournalForBookMarkedNews
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
                throw MemoError.noTempJournalForNews
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
            if let memo = journal.journal {
                return memo.title
            } else {
                throw MemoError.noJournalToRetrieve
            }
        } else {
            throw MemoError.noBookMarkedNewsToRetrieve
        }
    }
    
    func retrieveJournalContent() throws -> String {
        if let id = objectId, let bookmarkedNews = repository.fetchSingleRecord(objectId: id) {
            if let journal = bookmarkedNews.journal {
                return journal.content
            } else {
                throw MemoError.noJournalToRetrieve
            }
        } else {
            throw MemoError.noBookMarkedNewsToRetrieve
        }
    }
    
    func retrieveTagTable() throws -> TagTable {
        if let id = objectId, let bookmarkedNews = repository.fetchSingleRecord(objectId: id) {
            guard let journal = bookmarkedNews.journal else { throw MemoError.noJournalToRetrieve }
            guard let tagTable = journal.tags else { throw MemoError.noTagToRetrieve }
            return tagTable
        } else {
            if let news = news {
                throw MemoError.noTagForDTONews
            } else {
                throw MemoError.noBookMarkedNewsToRetrieve
            }
        }
    }
    
    func handleMemo(title: String, content: String) throws {
        
        let newMemo = Journal()
        newMemo.title = title
        newMemo.content = removeMultipleNewLinesInContent(content: content)
        newMemo.editedAt = Date()
        
        if let objectId = objectId {
            //기존 메모 수정
            guard let bookmarkedNews = repository.fetchSingleRecord(objectId: objectId) else { throw MemoError.noBookMarkedNewsToRetrieve }
            if let existingMemo = bookmarkedNews.journal {
                newMemo.createdAt = existingMemo.createdAt
                journalTableToBeSaved.value = newMemo
            } else {
                newMemo.createdAt = Date()
                journalTableToBeSaved.value = newMemo
            }
        } else {
            //새로운 메모 생성
            newMemo.createdAt = Date()
            journalTableToBeSaved.value = newMemo
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
        
        journalTableToBeSaved.value?.tags = tagTableToBeSaved.value
        
        //최종 저장하기
        if let id = objectId {
            //기존 저널 수정하기
            guard let bookmarkedNews = repository.fetchSingleRecord(objectId: id) else {
                //해당 저널 존재하지 않음: alert or toast message
                memoErrorMessage.value = MemoError.noBookMarkedNewsToRetrieve.alertMessage
                return
            }
            
            var isJournalNewlyCreated: Bool
            if let existingJournal = bookmarkedNews.journal {
                isJournalNewlyCreated = false
            } else {
                isJournalNewlyCreated = true
            }
            
            //존재: 수정, 존재하지 않으면 새로 할당 (어차피 새로 할당하는 작업은 동일)
            guard let newJournal = journalTableToBeSaved.value else { return }
            
            //업데이트 하려고 준비한 메모 및 태그로 저장하기
            do {
                try repository.updateRecordOfJournal(record: bookmarkedNews, newJournal: newJournal)
                //성공 toast 메시지 띄우기
                memoSuccessMessage.value = isJournalNewlyCreated ? MemoSetupValues.savingNewlyCreatedJournalSucceed : MemoSetupValues.updatingJournalSucceed
                bookmarkedNewsLinkForNotification = bookmarkedNews.link
                
                //remove from UserDefaults: 실패를 굳이 알려야 하는지 의문...
                if userDefault.deleteFromUserDefaults(type: String.self, forKey: bookmarkedNews.title) {
                    if !userDefault.deleteFromUserDefaults(type: String.self, forKey: "\(id)") {
                        //임시 memo 삭제 실패 toast
                        memoErrorMessage.value = MemoSetupValues.deletionTempMemoFailed
                    }
                    switch bookmarkedNews.apiType {
                    case .naver:
                        isJournalMadeFromNaver.value = true
                    case .mediaStack:
                        isJournalMadeFromMediaStack.value = true
                    case .newsAPI:
                        isJournalMadeFromNewsAPI.value = true
                    }
                } else {
                    //임시 title 삭제 실패 toast
                    memoErrorMessage.value = MemoSetupValues.deletionTempTitleFailed
                }
            } catch {
                //수정 실패: toast 띄우기
                memoErrorMessage.value = MemoSetupValues.updatingJournalFailed
                switch bookmarkedNews.apiType {
                case .naver:
                    isJournalMadeFromNaver.value = false
                case .mediaStack:
                    isJournalMadeFromMediaStack.value = false
                case .newsAPI:
                    isJournalMadeFromNewsAPI.value = false
                }
            }
        } else {
            guard let news = news else { return }
            
            let newlyBookmarkedNews = BookMarkedNews(title: news.title, newsDescription: news.description, pubDate: news.pubDate, link: news.urlLink, apiType: currentApiType)
            newlyBookmarkedNews.journal = journalTableToBeSaved.value
            
            do {
                try repository.createRecord(record: newlyBookmarkedNews)
                //저장 완료 toast 띄우기
                memoSuccessMessage.value = MemoSetupValues.savingNewlyCreatedJournalSucceed
                bookmarkedNewsLinkForNotification = newlyBookmarkedNews.link
                
                //remove from UserDefaults: 실패를 굳이 알려야 하는지 의문...
                if userDefault.deleteFromUserDefaults(type: String.self, forKey: news.title) {
                    if !userDefault.deleteFromUserDefaults(type: String.self, forKey: news.id) {
                        //임시 memo 제거 에러 toast 띄우기
                        memoErrorMessage.value = MemoSetupValues.deletionTempMemoFailed
                    }
                    switch newlyBookmarkedNews.apiType {
                    case .naver:
                        isJournalMadeFromNaver.value = true
                    case .mediaStack:
                        isJournalMadeFromMediaStack.value = true
                    case .newsAPI:
                        isJournalMadeFromNewsAPI.value = true
                    }
                } else {
                    //임시 title 제거 에러 toast 띄우기
                    memoErrorMessage.value = MemoSetupValues.deletionTempTitleFailed
                    switch newlyBookmarkedNews.apiType {
                    case .naver:
                        isJournalMadeFromNaver.value = true
                    case .mediaStack:
                        isJournalMadeFromMediaStack.value = true
                    case .newsAPI:
                        isJournalMadeFromNewsAPI.value = true
                    }
                }
            } catch {
                //저장 실패: toast 띄우기
                memoErrorMessage.value = MemoSetupValues.savingNewlyCreatedJournalFailed
                switch newlyBookmarkedNews.apiType {
                case .naver:
                    isJournalMadeFromNaver.value = false
                case .mediaStack:
                    isJournalMadeFromMediaStack.value = false
                case .newsAPI:
                    isJournalMadeFromNewsAPI.value = false
                }
            }
        }
        
    }
    
    //MARK: - API
    
    func updateAPIType(newType: APIType) {
        currentApiType = newType
    }
    
    func retrieveBookMarkedNewsWithJournalLink() -> String {
        return bookmarkedNewsLinkForNotification
    }

}
