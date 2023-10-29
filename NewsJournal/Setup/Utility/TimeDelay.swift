//
//  TimeDelay.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/27.
//

import Foundation

extension Constant {
    
    enum TimeDelay {
        
        static let toastMessageDelay: TimeInterval = 2
        static let skeletonDispatchAsyncAfter: DispatchTime = .now() + 2
        static let optionViewAnimationDuration: TimeInterval = 0.4
    }
    
}
