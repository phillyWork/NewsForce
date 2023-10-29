//
//  Extension+String.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/03.
//

import UIKit

extension String {
    
    func height(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    func htmlAttributedString(value: String) -> String {
        guard let data = value.data(using: .utf8) else { return value }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html,
                                                                .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil).string
        } catch {
            return value
        }
    }
    
    func toDateWithNaverType() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.date(from: self)
    }
    
    func toDateWithMediaStackAndNewsAPI() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.date(from: self)
    }
    
    func toAddORInSpaceBetweenQueryWordsForNewsAPI() -> String {
        return self.components(separatedBy: Constant.APISetup.oRInASCII).joined(separator: Constant.APISetup.newsAPIQueryORInput)
    }
    
    func toAddANDInSpaceBetweenQueryWordsForNewsAPI() -> String {
        return self.components(separatedBy: Constant.APISetup.oRInASCII).joined(separator: Constant.APISetup.newsAPIQueryANDInput)
    }
    
}
