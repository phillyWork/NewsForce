//
//  Repository.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import Foundation
import RealmSwift

final class Repository: RealmRepositoryProtocol {
    
    //MARK: - Properties
    
    static let shared = Repository()
    private init() { }
    
    private let realm = try? Realm()
    
    //MARK: - CREATE
    
    func createRecord<T:Object>(record: T) throws {
        print(#function)
        if let realm = realm {
            do {
                try realm.write {
                    realm.add(record)
                }
            } catch {
                throw RealmError.createObjectFailure
            }
        }
    }
    
    //MARK: - READ
    
    private func retrieveDefaultRealmPath() -> URL? {
        guard let realm = realm, let realmPath = realm.configuration.fileURL else { return nil }
        return realmPath
    }
    
    func checkSchemaVersion() throws {
        do {
            if let realmPath = retrieveDefaultRealmPath() {
                print("realmPath: \(realmPath)")
                let schemaVersion = try schemaVersionAtURL(realmPath)
                print("schemaVersion: \(schemaVersion)")
            }
        } catch {
            throw RealmError.checkSchemaFailure
        }
    }

    func fetch<T:Object>(type: T.Type) -> Results<T>? {
        guard let realm = realm else { return nil }
        return realm.objects(T.self).sorted(byKeyPath: RealmSetupValues.editedAtKeyPath, ascending: false)
    }
    
    func fetchSingleRecord(objectId: ObjectId) -> BookMarkedNews? {
        guard let realm = realm else { return nil }
        return realm.object(ofType: BookMarkedNews.self, forPrimaryKey: objectId)
    }
    
    func fetchWithTag(type: TagType) -> Results<BookMarkedNews>? {
        return fetch(type: BookMarkedNews.self)?.where { ($0.journal.tags.firstTag == type) || ($0.journal.tags.secondTag == type) || ($0.journal.tags.thirdTag == type) }
    }
    
    func fetchWithJournal(text: String) -> Results<BookMarkedNews>? {
        return fetch(type: BookMarkedNews.self)?.where { $0.journal.content.contains(text) }
    }
    
    func fetchWithTagAndJournal(type: TagType, text: String) -> Results<BookMarkedNews>? {
        return fetchWithTag(type: type)?.where { $0.journal.content.contains(text) }
    }
    
    func fetchWithoutSelectedBookMarkedNews(selected: Dictionary<IndexPath, BookMarkedNews>) -> Results<BookMarkedNews>? {
        var retrieved = fetch(type: BookMarkedNews.self)
        
        for journal in selected.values {
            retrieved = retrieved?.where { $0._id != journal._id }
        }
        return retrieved
    }
    
    func fetchWithoutSelectedBookMarkedNewsWithinTag(selected: Dictionary<IndexPath, BookMarkedNews>, type: TagType) -> Results<BookMarkedNews>? {
        var retrievedWithTag = fetchWithTag(type: type)
        for journal in selected.values {
            retrievedWithTag = retrievedWithTag?.where { $0._id != journal._id }
        }
        return retrievedWithTag
    }
    
    func fetchWithLink(link: String) -> Results<BookMarkedNews>? {
        return fetch(type: BookMarkedNews.self)?.where { $0.link.contains(link) }
    }

    func fetchJournalWithLink(link: String) -> Results<BookMarkedNews>? {
        return fetchWithLink(link: link)?.where { $0.journal != nil }
    }
    
    func fetchOnlyBookMarkedNewsContainingJournal() -> Results<BookMarkedNews>? {
        return fetch(type: BookMarkedNews.self)?.where { $0.journal != nil }
    }
    
    func fetchOnlyBookMarkedNewsContainingJournalWithTag(type: TagType) -> Results<BookMarkedNews>? {
        return fetchWithTag(type: type)?.where { $0.journal != nil }
    }
    
    func fetchBookMarkedNewsExcludingSpecificNews(exclude: BookMarkedNews) -> Results<BookMarkedNews>? {
        return fetch(type: BookMarkedNews.self)?.where { $0._id != exclude._id }
    }
    
    func fetchBookMarkedNewsExcludingSpecificNewsWithTag(type: TagType, exclude: BookMarkedNews) -> Results<BookMarkedNews>? {
        return fetchWithTag(type: type)?.where { $0._id != exclude._id }
    }
    
    func fetchBookMarkedNewsWithoutLink(links: [String]) -> Results<BookMarkedNews>? {
        return fetch(type: BookMarkedNews.self)?.where { !$0.link.in(links) }
    }
    
    func fetchBookMarkedNewsWithoutLinkWithinTag(type: TagType, links: [String]) -> Results<BookMarkedNews>? {
        return fetchWithTag(type: type)?.where { !$0.link.in(links) }
    }
    
    //MARK: - UPDATE
    
    func updateRecordOfJournal(record: BookMarkedNews, newJournal: Journal) throws {
        if let realm = realm {
            do {
                try realm.write {
                    record.journal = newJournal
                }
            } catch {
                throw RealmError.updateObjectFailure
            }
        }
    }
    
    //MARK: - DELETE
    
    func deleteRecord<T:Object>(record: T) throws {
        if let realm = realm {
            do {
                try realm.write {
                    realm.delete(record)
                }
            } catch {
                throw RealmError.deleteObjectFailure
            }
        }
    }
    
    func deleteRecords(records: Results<BookMarkedNews>) throws {
        print(#function)
        if let realm = realm {
            do {
                try realm.write {
                    realm.delete(records)
                }
            } catch {
                throw RealmError.deleteObjectFailure
            }
        }
    }
 
    
    //MARK: - CRUD For Search Keyword
    
    func fetchUserSearchKeywords() -> Results<UserSearchKeyword>? {
        guard let realm = realm else { return nil }
        let sortProperties = [SortDescriptor(keyPath: RealmSetupValues.searchWordCount, ascending: false), SortDescriptor(keyPath: RealmSetupValues.lastTimeSearchedAt, ascending: false)]
        return realm.objects(UserSearchKeyword.self).sorted(by: sortProperties)
    }

    func fetchUserSearchKeywordsWithoutThatKeyword(keyword: UserSearchKeyword) -> Results<UserSearchKeyword>? {
        guard let realm = realm else { return nil }
        let sortProperties = [SortDescriptor(keyPath: RealmSetupValues.searchWordCount, ascending: false), SortDescriptor(keyPath: RealmSetupValues.lastTimeSearchedAt, ascending: false)]
        return realm.objects(UserSearchKeyword.self).where { $0.searchWord != keyword.searchWord }.sorted(by: sortProperties)
    }
    
    func fetchSingleUserSearchKeyWord(word: String) -> UserSearchKeyword? {
        guard let realm = realm else { return nil }
        return realm.object(ofType: UserSearchKeyword.self, forPrimaryKey: word)
    }
    
    func updateUserSearchKeyword(task: [String : Any]) throws {
        if let realm = realm {
            do {
                try realm.write {
                    realm.create(UserSearchKeyword.self, value: task, update: .modified)
                }
            } catch {
                throw RealmError.updateObjectFailure
            }
        }
    }
    
    func deleteSearchWord(word: UserSearchKeyword) throws {
        if let realm = realm {
            do {
                try realm.write {
                    realm.delete(word)
                }
            } catch {
                throw RealmError.deleteObjectFailure
            }
        }
    }
    
}
