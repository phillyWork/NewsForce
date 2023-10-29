//
//  NewsMemoViewModel.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import Foundation

import RealmSwift

final class JournalViewModel {
    
    //MARK: - Properties
    
    var currentTagType: Observable<TagType> = Observable(.whole)
    var retrievedBookMarkedNews: Observable<Results<BookMarkedNews>?> = Observable(nil)
    
    var realmErrorMessage: Observable<String> = Observable("")
    var realmSucceedMessage: Observable<String> = Observable("")
    
    var isEmptyView = Observable(false)
    
    //indexPath.row : BookMarkedNews
    private var selectedBookMarkedNews: Dictionary<IndexPath, BookMarkedNews> = [:]
        
    private let repository = Repository.shared

    //MARK: - Retrieve API
    
    func retrieveJournals() {
        print(#function)
        if let journals = repository.fetch(type: BookMarkedNews.self) {
            retrievedBookMarkedNews.value = journals
            isEmptyView.value = journals.isEmpty ? true : false
        } else {
            //empty view
            isEmptyView.value = true
        }
    }
    
    func retrieveBookMarkedNewsWithContents(_ text: String) {
        if currentTagType.value != .whole {
            if let news = repository.fetchWithTagAndJournal(type: currentTagType.value, text: text) {
                retrievedBookMarkedNews.value = news
                isEmptyView.value = news.isEmpty ? true : false
            } else {
                isEmptyView.value = true
            }
        } else {
            if let news = repository.fetchWithJournal(text: text) {
                retrievedBookMarkedNews.value = news
                isEmptyView.value = news.isEmpty ? true : false
            } else {
                //empty view
                isEmptyView.value = true
            }
        }
    }
    
    func retrieveBookMarkedNewsWithTag() {
        print(#function)
        //none 버튼 존재하지 않음
        if currentTagType.value != .whole {
            if let news = repository.fetchWithTag(type: currentTagType.value) {
                retrievedBookMarkedNews.value = news
                isEmptyView.value = news.isEmpty ? true : false
            } else {
                //empty view
                isEmptyView.value = true
            }
        } else {
            retrieveJournals()
        }
    }
    
    func retrieveWithoutSelectedTag() {
        //해당 tag 포함 저널만
        if let news = repository.fetchWithoutSelectedBookMarkedNewsWithinTag(selected: selectedBookMarkedNews, type: currentTagType.value) {
            retrievedBookMarkedNews.value = news
            isEmptyView.value = news.isEmpty ? true : false
        } else {
            isEmptyView.value = true
        }
    }
    
    func retrieveWithoutSelected() {
        //전체 저널
        if let journals = repository.fetchWithoutSelectedBookMarkedNews(selected: selectedBookMarkedNews) {
            retrievedBookMarkedNews.value = journals
            isEmptyView.value = journals.isEmpty ? true : false
        } else {
            isEmptyView.value = true
        }
    }
    
    func retrieveSelectedBookMarkedNews() -> Dictionary<IndexPath, BookMarkedNews> {
        return selectedBookMarkedNews
    }
    
    func retrieveOnlyBookMarkedNewsWithJournal() {
        if currentTagType.value != .whole {
            if let newsContainingJournalWithTag = repository.fetchOnlyBookMarkedNewsContainingJournalWithTag(type: currentTagType.value) {
                retrievedBookMarkedNews.value = newsContainingJournalWithTag
                isEmptyView.value = newsContainingJournalWithTag.isEmpty ? true : false
            } else {
                isEmptyView.value = true
            }
        } else {
            if let newsContainingJournal = repository.fetchOnlyBookMarkedNewsContainingJournal() {
                retrievedBookMarkedNews.value = newsContainingJournal
                isEmptyView.value = newsContainingJournal.isEmpty ? true : false
            } else {
                isEmptyView.value = true
            }
        }
    }
    
    func retrieveBookMarkedNewsExcudingLinksWithTag(links: [String]) {
        if currentTagType.value != .whole {
            if let booksExcludingLinksWithinTag = repository.fetchBookMarkedNewsWithoutLinkWithinTag(type: currentTagType.value, links: links) {
                retrievedBookMarkedNews.value = booksExcludingLinksWithinTag
                isEmptyView.value = booksExcludingLinksWithinTag.isEmpty ? true : false
            } else {
                isEmptyView.value = true
            }
        } else {
            if let booksExcludingLinks = repository.fetchBookMarkedNewsWithoutLink(links: links) {
                retrievedBookMarkedNews.value = booksExcludingLinks
                isEmptyView.value = booksExcludingLinks.isEmpty ? true : false
            } else {
                isEmptyView.value = true
            }
        }
    }
    
    func updateSnapshotBeforeUnBookMark(bookMarked: BookMarkedNews) {
        print(#function)
        if currentTagType.value != .whole {
            if let updateJournalWithoutSpecificBookMarkWithTag = repository.fetchBookMarkedNewsExcludingSpecificNewsWithTag(type: currentTagType.value, exclude: bookMarked) {
                retrievedBookMarkedNews.value = updateJournalWithoutSpecificBookMarkWithTag
                isEmptyView.value = updateJournalWithoutSpecificBookMarkWithTag.isEmpty ? true : false
            } else {
                isEmptyView.value = true
            }
        } else {
            if let updateJournalWithoutSpecificBookMark = repository.fetchBookMarkedNewsExcludingSpecificNews(exclude: bookMarked) {
                retrievedBookMarkedNews.value = updateJournalWithoutSpecificBookMark
                isEmptyView.value = updateJournalWithoutSpecificBookMark.isEmpty ? true : false
            } else {
                isEmptyView.value = true
            }
        }
    }
    
    func resetAndRetrieveBookMarkedNewsWithTagByNotification() {
        print(#function)
        retrievedBookMarkedNews.value = nil
        retrieveBookMarkedNewsWithTag()
    }
    
    
    //MARK: - Multiple Selection API
    
    func clearSelectedJournals() {
        selectedBookMarkedNews.removeAll()
    }
    
    func insertSelectedJournal(indexPath: IndexPath, selected: BookMarkedNews) {
        selectedBookMarkedNews[indexPath] = selected
    }
    
    func removeSelectedJournal(indexPath: IndexPath, selected: BookMarkedNews) -> Bool {
        if selectedBookMarkedNews[indexPath] == selected {
            selectedBookMarkedNews.removeValue(forKey: indexPath)
            return true
        } else {
            realmErrorMessage.value = JournalRealmSetupValues.noJournalToBeDeselected
            return false
        }
    }
    
    func passSelectedJournals() -> [BookMarkedNews] {
        
        var journalsInArray = [BookMarkedNews]()
        
        for value in selectedBookMarkedNews.values {
            journalsInArray.insert(value, at: 0)
        }
        return journalsInArray.sorted { $0.journal!.editedAt < $1.journal!.editedAt }
    }
    
    func checkSelectedJournalsEmpty() -> Bool {
        return selectedBookMarkedNews.isEmpty ? true: false
    }
    
    func removeSelectedJournals() {
        for (_, journal) in selectedBookMarkedNews {
            do {
                try repository.deleteRecord(record: journal)
            } catch {
                realmErrorMessage.value = RealmError.deleteObjectFailure.alertMessage
            }
        }
    }
    
    func updateSnapshotBeforeDeletion() {
        guard !(selectedBookMarkedNews.isEmpty) else { return }
        
        //none 버튼 존재하지 않음
        if currentTagType.value != .whole {
            retrieveWithoutSelectedTag()
        } else {
            retrieveWithoutSelected()
        }
    }
    
    //MARK: - TagType API
        
    func updateTagType(newType: TagType) {
        currentTagType.value = newType
    }
    
    func checkSameTagType(_ senderType: TagType) -> Bool {
        return currentTagType.value == senderType ? true : false
    }
    
    //MARK: - PDF API
    
    func createPDFData() -> Data {
        //create PDF Data
        let pdfData = PDFDocumentCreator(passSelectedJournals()).createPDFDocumentData()
        return pdfData
    }
    
    //MARK: - BookMark Button API
    
    func checkMemoExistsInBookMarkedNewsWithLink(bookMarked: Results<BookMarkedNews>) -> Bool {
        let resultsInArray = Array(bookMarked)
        for bookmarkedNews in resultsInArray {
            if let _ = bookmarkedNews.journal {
                return true
            }
        }
        return false
    }
    
    func removeBookMarkedNewsFromRealm(bookMarkedNews: BookMarkedNews) {
        do {
            try repository.deleteRecord(record: bookMarkedNews)
        } catch {
            //error 처리
            
        }
        
    }
    
    //MARK: - Dynamic Height Composition API

    func calculateRatios(contentWidth: CGFloat, journals: [BookMarkedNews]) -> [Ratio] {
        
        let width = (contentWidth - Constant.Frame.journalCollectionViewGroupInterItemSpace - Constant.Frame.journalCollectionViewSpacingForDoublePadding) / 2
        var ratios = [Ratio]()
        
        for journal in journals {
            guard let memoHeight = journal.journal?.content.height(width: width, font: Constant.Font.journalRealmCellMemo) else  { continue }
            //cell height = titleTopOffset + titleHeight + titleBottomEditedTopOffset + editedHeight + editedBottomTagTopOffset + tagBottomMemoTopOffset + memoHeight + memoBottomOffset
            
            let titleHeight = (width - Constant.Frame.journalRealmCellLabelInset) * Constant.Frame.journalRealmCellTitleLabelHeightMultiply
            let editedDateHeight = (width - Constant.Frame.journalRealmCellLabelInset) * Constant.Frame.journalRealmCellDateHeightMultiply
            let tagHeight = (width - Constant.Frame.journalRealmCellLabelInset) * Constant.Frame.journalRealmCellTagHeightMultiply
            
            let offsetForDateAndTag = Constant.Frame.journalRealmCellDateTagInset
            let offsetForTitleAndMemo = Constant.Frame.journalRealmCellLabelInset
            
            let height = offsetForTitleAndMemo * 3 + titleHeight + offsetForDateAndTag * 2 + editedDateHeight + tagHeight + memoHeight
            
            ratios.append(Ratio(ratio: width / height))
        }
        return ratios
    }
    
}
