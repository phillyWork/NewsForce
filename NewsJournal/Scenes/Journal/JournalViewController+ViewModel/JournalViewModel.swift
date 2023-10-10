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
    
    var currentTagType: Observable<TagType> = Observable(.none)
    var retrievedJournals: Observable<Results<Journal>?> = Observable(nil)
    
    var realmErrorMessage: Observable<String> = Observable("")
    var realmSucceedMessage: Observable<String> = Observable("")
    
    var isEmptyView = Observable(false)
    
    //indexPath.row : Journal
    private var selectedJournals: Dictionary<IndexPath, Journal> = [:]
        
    private let repository = Repository.shared

    //MARK: - Retrieve API
    
    func retrieveJournals() {
        if let journals = repository.fetch(type: Journal.self) {
            retrievedJournals.value = nil
            retrievedJournals.value = journals
            isEmptyView.value = journals.isEmpty ? true : false
        } else {
            //empty view
            isEmptyView.value = true
        }
    }
    
    func retrieveJournalsWithMemo(_ text: String) {
        if currentTagType.value != .none {
            if let journals = repository.fetchWithTagAndMemo(type: currentTagType.value, text: text) {
                retrievedJournals.value = nil
                retrievedJournals.value = journals
                isEmptyView.value = journals.isEmpty ? true : false
            } else {
                isEmptyView.value = true
            }
        } else {
            if let journals = repository.fetchWithMemo(text: text) {
                retrievedJournals.value = nil
                retrievedJournals.value = journals
                isEmptyView.value = journals.isEmpty ? true : false
            } else {
                //empty view
                isEmptyView.value = true
            }
        }
        
    }
    
    func retrieveJournalsWithTag() {
        if currentTagType.value != .none {
            if let journals = repository.fetchWithTag(type: currentTagType.value) {
                retrievedJournals.value = nil
                retrievedJournals.value = journals
                isEmptyView.value = journals.isEmpty ? true : false
            } else {
                //empty view
                isEmptyView.value = true
            }
        } else {
            retrieveJournals()
        }
    }
    
    func retrieveWithoutSelectedWithTag() {
        //해당 tag 포함 저널만
        if let journals = repository.fetchWithoutSelectedJournalsWithinTag(selected: selectedJournals, type: currentTagType.value) {
            retrievedJournals.value = nil
            retrievedJournals.value = journals
            isEmptyView.value = journals.isEmpty ? true : false
        } else {
            isEmptyView.value = true
        }
    }
    
    func retrieveWithoutSelected() {
        //전체 저널
        if let journals = repository.fetchWithoutSelectedJournals(selected: selectedJournals) {
            retrievedJournals.value = nil
            retrievedJournals.value = journals
            isEmptyView.value = journals.isEmpty ? true : false
        } else {
            isEmptyView.value = true
        }
    }
    
    func retrieveSelectedJournals() -> Dictionary<IndexPath, Journal> {
        return selectedJournals
    }
    
    //MARK: - Multiple Selection API
    
    func clearSelectedJournals() {
        selectedJournals.removeAll()
    }
    
    func insertSelectedJournal(indexPath: IndexPath, selected: Journal) {
        selectedJournals[indexPath] = selected
    }
    
    func removeSelectedJournal(indexPath: IndexPath, selected: Journal) -> Bool {
        if selectedJournals[indexPath] == selected {
            selectedJournals.removeValue(forKey: indexPath)
            return true
        } else {
            realmErrorMessage.value = JournalRealmSetupValues.noJournalToBeDeselected
            return false
        }
    }
    
    func passSelectedJournals() -> [Journal] {
        
        var journalsInArray = [Journal]()
        
        for value in selectedJournals.values {
            journalsInArray.insert(value, at: 0)
        }
        return journalsInArray.sorted { $0.memo!.editedAt < $1.memo!.editedAt }
    }
    
    func checkSelectedJournalsEmpty() -> Bool {
        return selectedJournals.isEmpty ? true: false
    }
    
    func removeSelectedJournals() {
        for (_, journal) in selectedJournals {
            do {
                try repository.deleteRecord(record: journal)
            } catch {
                realmErrorMessage.value = RealmError.deleteObjectFailure.alertMessage
            }
        }
    }
    
    func updateSnapshotBeforeDeletion() {
        guard !(selectedJournals.isEmpty) else { return }
        
        if currentTagType.value != .none {
            retrieveWithoutSelectedWithTag()
        } else {
            retrieveWithoutSelected()
        }
    }
    
    //MARK: - TagType API
    
    func resetTagType() {
        currentTagType.value = .none
    }
    
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
    
    
    //MARK: - Dynamic Height Composition API

    func calculateRatios(contentWidth: CGFloat, journals: [Journal]) -> [Ratio] {
        
        let width = (contentWidth - Constant.Frame.journalCollectionViewGroupInterItemSpace - Constant.Frame.journalCollectionViewSpacingForDoublePadding) / 2
        var ratios = [Ratio]()
        
        for journal in journals {
            guard let memoHeight = journal.memo?.content.height(width: width, font: Constant.Font.journalRealmCellMemo) else  { continue }
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
