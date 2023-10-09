//
//  WebViewController.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import UIKit
import WebKit

final class WebViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let webView = WKWebView()

    lazy private var backButton: CustomBarButtonItem = {
        let button = CustomBarButtonItem(type: .backToList)
        button.target = self
        button.action = #selector(backButtonTapped)
        return button
    }()
    
    lazy private var writeButton: CustomBarButtonItem = {
        let button = CustomBarButtonItem(type: .writeDownMemo)
        button.target = self
        button.action = #selector(writeDownButtonTapped)
        return button
    }()
        
    let webVM = WebViewModel()
    
    //MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webVM.webErrorMessage.bind { message in
            self.showErrorToastMessage(message: message)
        }
        
        populateViews()
        
        //MemoVC 저장 완료되어서 닫힘 알림받기
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmSavedObserverInWeb), name: .realmSaved, object: nil)
        //일단 닫힘 알리기
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCloseVC), name: .memoClosed, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //tabbar 다시 보이기
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func configureViews() {
        super.configureViews()
        
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = writeButton
        
        view.addSubview(webView)
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        webView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func populateViews() {
        do {
            let link = try webVM.retrieveLinkFromPassedData()
            try self.loadWebView(with: link)
        } catch WebViewError.noNewsToRetrieve {
            //전달받은 뉴스 없음
            self.alertToPop(title: WebViewError.noNewsToRetrieve.alertTitle, message: WebViewError.noNewsToRetrieve.alertMessage)
        } catch WebViewError.noJournalToRetrieve {
            //전달받은 id, realm에 journal 존재하지 않음
            self.alertToPop(title: WebViewError.noJournalToRetrieve.alertTitle, message: WebViewError.noJournalToRetrieve.alertMessage)
        } catch WebViewError.invalidURL {
            switch webVM.returnCurrentType() {
            case .newsSearchVC:
                self.alertToPop(title: WebViewError.invalidURL.alertTitle, message: WebViewError.invalidURL.alertMessage)
            case .journalVC:
                webVM.webErrorMessage.value = WebViewError.invalidURL.alertMessage
                self.writeDownButtonTapped()
            }
        } catch {
            switch webVM.returnCurrentType() {
            case .newsSearchVC:
                self.alertToPop(title: WebViewError.unAvailableToLoad.alertTitle, message: WebViewError.unAvailableToLoad.alertMessage)
            case .journalVC:
                webVM.webErrorMessage.value = WebViewError.unAvailableToLoad.alertMessage
                self.writeDownButtonTapped()
            }
        }
    }
    
    //MARK: - Notification Observers
    
    @objc func notificationRealmSavedObserverInWeb() {
        //뒤로 가기
        navigationController?.popViewController(animated: true)
    }
    
    @objc func notificationCloseVC() {
        //memoVC 내려감: 뒤로 가기 버튼 활성화
        navigationItem.leftBarButtonItem?.isHidden = false
        navigationItem.rightBarButtonItem?.isHidden = false
    }
    
    //MARK: - Handlers
    
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func writeDownButtonTapped() {
        //nav의 버튼 눌리지 않도록 설정: 숨기기
        navigationItem.leftBarButtonItem?.isHidden = true
        navigationItem.rightBarButtonItem?.isHidden = true

        let memoVC = MemoViewController()
        switch webVM.returnCurrentType() {
        case .newsSearchVC:
            if let news = webVM.news {
                memoVC.memoVM.news = news
            }
        case .journalVC:
            if let id = webVM.objectId {
                memoVC.memoVM.objectId = id
            }
        }
        
        //setup Memo with SheetPresentation
        let nav = UINavigationController(rootViewController: memoVC)
        if let sheetPresentationController = nav.sheetPresentationController {
            sheetPresentationController.detents = [.medium(), .large()]
            sheetPresentationController.largestUndimmedDetentIdentifier = .medium
            sheetPresentationController.prefersGrabberVisible = true
            sheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        present(nav, animated: true)
    }
    
    
    //MARK: - API
    
    private func loadWebView(with link: String) throws {
        
        if let url = URL(string: link) {
            let request = URLRequest(url: url)
            guard webView.load(request) != nil else {
                throw WebViewError.unAvailableToLoad
            }
            self.writeDownButtonTapped()
        } else {
            throw WebViewError.invalidURL
        }
    }
    
    //MARK: - Deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .realmSaved, object: nil)
        NotificationCenter.default.removeObserver(self, name: .memoClosed, object: nil)
    }
    
}
