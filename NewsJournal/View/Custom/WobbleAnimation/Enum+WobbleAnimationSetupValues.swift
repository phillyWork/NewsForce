//
//  Enum+WobbleAnimationSetupValues.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/27.
//

import Foundation

enum WobbleAnimationSetupValues {
    
    static let keyPathString = "transform.rotation"
    static let valuesArray = [0.0, -0.025, 0.025, 0.0]
    static let keyTimesArray: [NSNumber] = [0.0, 0.25, 0.5, 0.75, 1.0]
    static let animationDuration = 0.4
    
}
