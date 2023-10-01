//
//  BaseViewController.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import UIKit
import SnapKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        setConstraints()
    }
    
    func configureViews() {
        view.backgroundColor = Constant.Color.whiteBackground
    }
    
    func setConstraints() {
        
    }
    
    
    
}
