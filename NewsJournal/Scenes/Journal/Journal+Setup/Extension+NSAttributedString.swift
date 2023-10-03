//
//  Extension+NSAttributedString.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/03.
//

import UIKit

extension NSAttributedString {
    
    func height(width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        return ceil(boundingBox.height)
    }
    
}
