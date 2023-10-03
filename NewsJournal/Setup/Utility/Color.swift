//
//  Color.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import UIKit

extension Constant {
    
    enum Color {
        
        static let whiteBackground = UIColor.white
        static let mainRed = UIColor(red: 179/255, green: 0, blue: 0, alpha: 1)
        static let journalBackgroundRandomRed = UIColor(red: 125/255, green: 0, blue: 0, alpha: CGFloat.random(in: 0.2...0.5))
        
        static let tagButtonText = UIColor(red: 166/255, green: 166/255, blue: 166/255, alpha: 1)
        static let searchBarText = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)

        static let cellShadow = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        
        static let linkDateShadowText = UIColor.lightGray
        
        
    }
    
}
