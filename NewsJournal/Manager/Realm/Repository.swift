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
        return realm.objects(T.self).sorted(byKeyPath: "memo.editedAt", ascending: false)
    }
    
    func fetchSingleRecord(objectId: ObjectId) -> Journal? {
        guard let realm = realm else { return nil }
        return realm.object(ofType: Journal.self, forPrimaryKey: objectId)
    }
    
    func fetchWithTag(type: TagType) -> Results<Journal>? {
        return fetch(type: Journal.self)?.where { ($0.memo.tags.firstTag == type) || ($0.memo.tags.secondTag == type) || ($0.memo.tags.thirdTag == type) }
    }
    
    func fetchWithMemo(text: String) -> Results<Journal>? {
        return fetch(type: Journal.self)?.where { $0.memo.content.contains(text) }
    }
    
    func fetchWithTagAndMemo(type: TagType, text: String) -> Results<Journal>? {
        return fetchWithTag(type: type)?.where { $0.memo.content.contains(text) }
    }
    
    func fetchWithoutSelectedJournals(selected: Dictionary<IndexPath, Journal>) -> Results<Journal>? {
        var retrieved = fetch(type: Journal.self)
        
        for journal in selected.values {
            retrieved = retrieved?.where { $0._id != journal._id }
        }
        return retrieved
    }
    
    func fetchWithoutSelectedJournalsWithinTag(selected: Dictionary<IndexPath, Journal>, type: TagType) -> Results<Journal>? {
        var retrievedWithTag = fetchWithTag(type: type)
        for journal in selected.values {
            retrievedWithTag = retrievedWithTag?.where { $0._id != journal._id }
        }
        return retrievedWithTag
    }
    
    //MARK: - UPDATE
    
    func updateRecordOfNews(task: [String : Any]) throws {
        if let realm = realm {
            do {
                try realm.write {
                    realm.create(Journal.self, value: task, update: .modified)
                }
            } catch {
                throw RealmError.updateObjectFailure
            }
        }
    }
    
    func updateRecordOfMemo(record: Journal, newMemo: MemoTable) throws {
        if let realm = realm {
            do {
                try realm.write {
                    record.memo = newMemo
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
    
}
