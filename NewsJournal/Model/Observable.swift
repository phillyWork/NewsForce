//
//  Observable.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/01.
//

import Foundation

final class Observable<T> {
    
    var listener: ((T) -> Void)?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ closure: @escaping ((T) -> Void) ) {
        listener = closure
    }
    
}
