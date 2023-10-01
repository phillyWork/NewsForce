//
//  UserDefaultsManager.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import Foundation

final class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    private init() { }
    
    private let userDefault = UserDefaults.standard
    
    //MARK: - READ
    
    func retrieveFromUserDefaults<T: Codable>(forKey: String) -> T? {
        if let retrievedData = userDefault.object(forKey: forKey) as? Data {
            let decoder = JSONDecoder()
            do {
                let data = try decoder.decode(T.self, from: retrievedData)
                return data
            } catch {
                return nil
            }
        }
        return nil
    }
    
    //MARK: - CREATE
    
    func saveToUserDefaults<T: Codable>(newValue: T, forKey: String) -> Bool {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(newValue)
            userDefault.setValue(encoded, forKey: forKey)
            return true
        } catch {
            return false
        }
    }
    
    //MARK: - DELETE
    
    func deleteFromUserDefaults<T: Codable>(type: T.Type, forKey: String) -> Bool {
        userDefault.removeObject(forKey: forKey)
        if let _ = retrieveFromUserDefaults(forKey: forKey) as T? {
            return false
        } else {
            return true
        }
    }
    
}
