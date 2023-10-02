//
//  BaseViewController.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import UIKit
import SnapKit
import JDStatusBarNotification

class BaseViewController: UIViewController {

    let toastManager = NotificationPresenter.shared()
    
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
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default)
        
        alert.addAction(confirm)
        self.present(alert, animated: true)
    }
    
}
