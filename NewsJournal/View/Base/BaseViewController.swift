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

    let toastManager = NotificationPresenter.shared
    
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
    
    //MARK: - Toast
    
    func showConfirmToastMessage(message: String) {
        toastManager.updateDefaultStyle { style in
            style.backgroundStyle.backgroundColor = Constant.Color.mainRed
            style.textStyle.textColor = Constant.Color.whiteBackground
            style.textStyle.font = Constant.Font.toastMessageFont
            style.canSwipeToDismiss = true
            style.leftViewStyle.tintColor = Constant.Color.whiteBackground
            return style
        }
        
        toastManager.present(message, duration: Constant.TimeDelay.toastMessageDelay)
//        toastManager.present(text: message, dismissAfterDelay: Constant.TimeDelay.toastMessageDelay)
        toastManager.displayLeftView(UIImageView(image: UIImage(systemName: Constant.ImageString.checkImageString)))
    }
    
    func showErrorToastMessage(message: String) {
        toastManager.updateDefaultStyle { style in
            style.backgroundStyle.backgroundColor = Constant.Color.tagButtonText
            style.textStyle.textColor = Constant.Color.whiteBackground
            style.textStyle.font = Constant.Font.toastMessageFont
            style.canSwipeToDismiss = true
            style.leftViewStyle.tintColor = Constant.Color.whiteBackground
            return style
        }
        
        toastManager.present(message, duration: Constant.TimeDelay.toastMessageDelay)
//        toastManager.present(text: message, dismissAfterDelay: Constant.TimeDelay.toastMessageDelay)
        toastManager.displayLeftView(UIImageView(image: UIImage(systemName: Constant.ImageString.xmarkCircleImageString)))
    }
    
    
    //MARK: - Alert
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: AlertConfirmText.basicConfirm, style: .default)
        
        alert.addAction(confirm)
        self.present(alert, animated: true)
    }
    
    func alertToPop(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmToPop = UIAlertAction(title: AlertConfirmText.confirmToPop, style: .default) { action in
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(confirmToPop)
        self.present(alert, animated: true)
    }
    
    func alertToPopRoot(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmToRoot = UIAlertAction(title: AlertConfirmText.confirmToRoot, style: .default) { action in
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        alert.addAction(confirmToRoot)
        self.present(alert, animated: true)
    }
    
}
