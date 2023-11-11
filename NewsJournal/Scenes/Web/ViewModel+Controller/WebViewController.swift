//
//  WebViewController.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import UIKit
import WebKit

import FirebaseAnalytics

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
        
    lazy private var swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeToBack))
    
    private var apiType: APIType = .naver
    
    let webVM = WebViewModel()
    
    //MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webVM.webErrorMessage.bind { message in
            self.showErrorToastMessage(message: message)
        }
        
        populateViews()
        
        //MemoVC 저장 완료되어서 닫힘 알림받기
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmSavedObserverInWeb), name: .journalSavedInMemoVCFromNaver, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmSavedObserverInWeb), name: .journalSavedInMemoVCFromMediaStack, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmSavedObserverInWeb), name: .journalSavedInMemoVCFromNewsAPI, object: nil)
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
        
        if #available(iOS 16.0, *) {
            navigationItem.leftBarButtonItem = backButton
            navigationItem.rightBarButtonItem = writeButton
        } else {
            navigationItem.setRightBarButton(writeButton, animated: true)
            navigationItem.setLeftBarButton(backButton, animated: true)
            navigationItem.setHidesBackButton(true, animated: true)
        }
        
        swipeGestureRecognizer.direction = .right
        view.addGestureRecognizer(swipeGestureRecognizer)

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
        }
//        catch WebViewError.invalidURL {
//            switch webVM.returnCurrentType() {
//            case .defaultNewsAsHome:
//                print("invalidURL with defaultNewsHomeViewController")
//            case .newsSearchWithRecentWords:
//                self.alertToPop(title: WebViewError.invalidURL.alertTitle, message: WebViewError.invalidURL.alertMessage)
//            case .journalWithPinnedNews:
//                webVM.webErrorMessage.value = WebViewError.invalidURL.alertMessage
//                self.writeDownButtonTapped()
//            }
//        }
    catch {
            webVM.webErrorMessage.value = WebViewError.invalidURL.alertMessage
            self.writeDownButtonTapped()
//            switch webVM.returnCurrentType() {
//            case .defaultNewsAsHome:
//                print("unavailableToLoad with defaultNewsHomeViewController")
//            case .newsSearchWithRecentWords:
//                self.alertToPop(title: WebViewError.unAvailableToLoad.alertTitle, message: WebViewError.unAvailableToLoad.alertMessage)
//            case .journalWithPinnedNews:
//                webVM.webErrorMessage.value = WebViewError.unAvailableToLoad.alertMessage
//                self.writeDownButtonTapped()
//            }
        }
    }
    
    //MARK: - Notification Observers
    
    @objc func notificationRealmSavedObserverInWeb() {
        //뒤로 가기
        navigationController?.popViewController(animated: true)
    }
    
    @objc func notificationCloseVC() {
        //memoVC 내려감: 뒤로 가기 버튼 활성화
        if #available(iOS 16.0, *) {
            navigationItem.leftBarButtonItem?.isHidden = false
            navigationItem.rightBarButtonItem?.isHidden = false
        } else {
            navigationItem.setLeftBarButton(backButton, animated: true)
            navigationItem.setRightBarButton(writeButton, animated: true)
        }
    }
    
    //MARK: - Handlers
    
    @objc private func handleSwipeToBack(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            self.navigationController?.popViewController(animated: true)
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "Web-01",
            AnalyticsParameterItemName: "WebSwipeToGoBack",
            AnalyticsParameterContentType: "swipeToGoBack"
        ])
    }
    
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "Web-02",
            AnalyticsParameterItemName: "WebBackButton",
            AnalyticsParameterContentType: "backButtonTapped"
        ])
    }
    
    @objc private func writeDownButtonTapped() {
        //nav의 버튼 눌리지 않도록 설정: 숨기기
        if #available(iOS 16.0, *) {
            navigationItem.leftBarButtonItem?.isHidden = true
            navigationItem.rightBarButtonItem?.isHidden = true
        } else {
            navigationItem.setLeftBarButton(nil, animated: true)
            navigationItem.setRightBarButton(nil, animated: true)
            navigationItem.setHidesBackButton(true, animated: true)
        }

        let memoVC = MemoViewController()
        memoVC.memoVM.updateAPIType(newType: webVM.passAPIType())
        
        if let id = webVM.objectId {
            memoVC.memoVM.objectId = id
        } else if let news = webVM.news {
            memoVC.memoVM.news = news
        } else {
            webVM.webErrorMessage.value = WebViewSetupValues.unavailableToLoadMemo
            return
        }

        //setup Memo with SheetPresentation
        let nav = UINavigationController(rootViewController: memoVC)
        if #available(iOS 16.0, *) {
            let detentIdentifier = UISheetPresentationController.Detent.Identifier(WebViewSetupValues.sheetPresentationDetentIdentifier)
            let customDetent = UISheetPresentationController.Detent.custom(identifier: detentIdentifier) { _ in
                return self.view.safeAreaLayoutGuide.layoutFrame.height * Constant.Frame.sheetPresentationDetentHeightMultiply
            }
            if let sheetPresentationController = nav.sheetPresentationController {
                sheetPresentationController.detents = [.large(), customDetent ]
                sheetPresentationController.largestUndimmedDetentIdentifier = customDetent.identifier
                sheetPresentationController.prefersGrabberVisible = true
                sheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge = false
            }
            present(nav, animated: true)
        } else {
            if let sheetPresentationController = nav.sheetPresentationController {
                sheetPresentationController.detents = [.medium(), .large()]
                sheetPresentationController.largestUndimmedDetentIdentifier = .medium
                sheetPresentationController.prefersGrabberVisible = true
                sheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge = false
            }
            present(nav, animated: true)
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "Web-03",
            AnalyticsParameterItemName: "WebWriteJournalButton",
            AnalyticsParameterContentType: "writeJournalButtonTapped"
        ])
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
        print("deinit in MemoVC")
        NotificationCenter.default.removeObserver(self, name: .journalSavedInMemoVCFromNaver, object: nil)
        NotificationCenter.default.removeObserver(self, name: .journalSavedInMemoVCFromMediaStack, object: nil)
        NotificationCenter.default.removeObserver(self, name: .journalSavedInMemoVCFromNewsAPI, object: nil)
        NotificationCenter.default.removeObserver(self, name: .memoClosed, object: nil)
        self.view.removeGestureRecognizer(swipeGestureRecognizer)
    }
    
}
