//
//  CustomWobbleAnimation.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/27.
//

import UIKit

final class CustomWobbleAnimation: CAKeyframeAnimation {
    
    override init() {
        super.init()
        configAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configAnimation() {
        keyPath = WobbleAnimationSetupValues.keyPathString
        values = WobbleAnimationSetupValues.valuesArray
        keyTimes = WobbleAnimationSetupValues.keyTimesArray
        duration = WobbleAnimationSetupValues.animationDuration
        isAdditive = true
        repeatCount = Float.greatestFiniteMagnitude
    }
    
}
