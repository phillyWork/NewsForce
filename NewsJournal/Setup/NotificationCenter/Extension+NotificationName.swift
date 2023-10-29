//
//  Extension+NotificationName.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import Foundation

extension Notification.Name {
    
    static let realmDeletedSourceFromNaver = Notification.Name("realmDeletedSourceFromNaver")
    static let realmDeletedSourceFromMediaStack = Notification.Name("realmDeletedSourceFromMediaStack")
    
    static let realmDeletedInSearchVCSourceFromNaver = Notification.Name("realmDeletedInSearchVCSourceFromNaver")
    static let realmDeletedInSearchVCSourceFromNewsAPI = Notification.Name("realmDeletedInSearchVCSourceFromNewsAPI")
    
    static let realmDeletedInJournalVCSourceFromNaver = Notification.Name("realmDeletedInJournalVCSourceFromNaver")
    static let realmDeletedInJournalVCSourceFromMediaStack = Notification.Name("realmDeletedInJournalVCSourceFromMediaStack")
    static let realmDeletedInJournalVCSourceFromNewsAPI = Notification.Name("realmDeletedInJournalVCSourceFromNewsAPI")
    
    static let realmSavedSourceFromNaver = Notification.Name("realmSavedSourceFromNaver")
    static let realmSavedSourceFromMediaStack = Notification.Name("realmSavedSourceFromMediaStack")
    
    static let realmSavedInSearchVCSourceFromNaver = Notification.Name("realmSavedInSearchVCSourceFromNaver")
    static let realmSavedInSearchVCSourceFromNewsAPI = Notification.Name("realmSavedInSearchVCSourceFromNewsAPI")
    
    static let journalSavedInMemoVCFromNaver = Notification.Name("journalSavedInMemoVCFromNaver")
    static let journalSavedInMemoVCFromMediaStack = Notification.Name("journalSavedInMemoVCFromMediaStack")
    static let journalSavedInMemoVCFromNewsAPI = Notification.Name("journalSavedInMemoVCFromNewsAPI")
    
    static let journalSavedSourceFromNaver = Notification.Name("journalSavedSourceFromNaver")
    static let journalSavedSourceFromMediaStack = Notification.Name("journalSavedSourceFromMediaStack")
    static let journalSavedSourceFromNewsAPI = Notification.Name("journalSavedSourceFromNewsAPI")
    
    static let memoClosed = Notification.Name("memoClosed")
    
}
