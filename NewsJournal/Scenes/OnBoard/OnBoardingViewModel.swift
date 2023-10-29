//
//  OnBoardingViewModel.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/10.
//

import Foundation

final class OnBoardingViewModel {
    
    //MARK: - Properties
    
    var willNotShowOnBoardingAgain: Observable<Bool> = Observable(false)
    
    
    //MARK: - API
    
    func isChecked() -> Bool {
        return willNotShowOnBoardingAgain.value
    }
    
    
}
