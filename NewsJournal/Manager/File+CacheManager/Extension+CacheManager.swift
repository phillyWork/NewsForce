//
//  Extension+CacheManager.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/15.
//

import Foundation
import LinkPresentation

extension CacheManager {
    
    //MARK: - Path
    
    private func retrieveDocumentsDirectory(fileName: String) -> URL? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        print("filePath: ", fileURL)
        return fileURL
    }
    
    //MARK: - Save
    
    func saveToDocuments(fileName: String, data: Data) throws {
        guard let url = retrieveDocumentsDirectory(fileName: fileName) else {
            throw CacheManagerError.noDocumentsDirectory
        }
        
        do {
            try data.write(to: url)
        } catch {
            throw CacheManagerError.savingFileFailure
        }
    }
    
    //MARK: - Load
    
    func loadFromDocuments(fileName: String) throws -> Data? {
        guard let url = retrieveDocumentsDirectory(fileName: fileName) else {
            throw CacheManagerError.noDocumentsDirectory
        }
        
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                let data = try Data(contentsOf: url)
                return data
            } catch {
                throw CacheManagerError.fetchingFileFailure
            }
        } else {
            throw CacheManagerError.fetchingFileFailure
        }
    }
    
    //MARK: - Delete
    
    func deleteFileInDocuments(fileName: String) throws {
        guard let url = retrieveDocumentsDirectory(fileName: fileName) else {
            throw CacheManagerError.noDocumentsDirectory
        }
        
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            throw CacheManagerError.fileDeletionFailure
        }
    }
    
}
