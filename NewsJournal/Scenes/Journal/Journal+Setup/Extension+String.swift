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
    
}
