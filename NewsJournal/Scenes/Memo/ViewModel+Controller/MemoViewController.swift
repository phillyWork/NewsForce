//
//  MemoViewController.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import UIKit

import FirebaseAnalytics

final class MemoViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let titleTextField = CustomTextField()
    private let contentTextView = CustomTextView()
    
    lazy private var firstTagButton = CustomPullDownButton()
    lazy private var secondTagButton = CustomPullDownButton()
    lazy private var thirdTagButton = CustomPullDownButton()
    
    lazy private var firstPolitics = UIAction(title: TagType.politics.rawValue) { _ in
        self.memoVM.firstTag = .politics
    }
    lazy private var firstEconomics = UIAction(title: TagType.economy.rawValue) { _ in
        self.memoVM.firstTag = .economy
    }
    lazy private var firstArt = UIAction(title: TagType.art.rawValue) { _ in
        self.memoVM.firstTag = .art
    }
    lazy private var firstEntertainment = UIAction(title: TagType.entertainment.rawValue) { _ in
        self.memoVM.firstTag = .entertainment
    }
    lazy private var firstScience = UIAction(title: TagType.science.rawValue) { _ in
        self.memoVM.firstTag = .science
    }
    lazy private var firstTechnology = UIAction(title: TagType.technology.rawValue) { _ in
        self.memoVM.firstTag = .technology
    }
    lazy private var firstHealth = UIAction(title: TagType.health.rawValue) { _ in
        self.memoVM.firstTag = .health
    }
    lazy private var firstLifestyle = UIAction(title: TagType.lifestyle.rawValue) { _ in
        self.memoVM.firstTag = .lifestyle
    }
    lazy private var firstSports = UIAction(title: TagType.sports.rawValue) { _ in
        self.memoVM.firstTag = .sports
    }
    lazy private var firstWorld = UIAction(title: TagType.world.rawValue) { _ in
        self.memoVM.firstTag = .world
    }
    lazy private var firstNone = UIAction(title: TagType.none.rawValue) { _ in
        self.memoVM.firstTag = .none
    }
    
    lazy private var secondPolitics = UIAction(title: TagType.politics.rawValue) { _ in
        self.memoVM.secondTag = .politics
    }
    lazy private var secondEconomics = UIAction(title: TagType.economy.rawValue) { _ in
        self.memoVM.secondTag = .economy
    }
    lazy private var secondArt = UIAction(title: TagType.art.rawValue) { _ in
        self.memoVM.secondTag = .art
    }
    lazy private var secondEntertainment = UIAction(title: TagType.entertainment.rawValue) { _ in
        self.memoVM.secondTag = .entertainment
    }
    lazy private var secondScience = UIAction(title: TagType.science.rawValue) { _ in
        self.memoVM.secondTag = .science
    }
    lazy private var secondTechnology = UIAction(title: TagType.technology.rawValue) { _ in
        self.memoVM.secondTag = .technology
    }
    lazy private var secondHealth = UIAction(title: TagType.health.rawValue) { _ in
        self.memoVM.secondTag = .health
    }
    lazy private var secondLifestyle = UIAction(title: TagType.lifestyle.rawValue) { _ in
        self.memoVM.secondTag = .lifestyle
    }
    lazy var secondSports = UIAction(title: TagType.sports.rawValue) { _ in
        self.memoVM.secondTag = .sports
    }
    lazy private var secondWorld = UIAction(title: TagType.world.rawValue) { _ in
        self.memoVM.secondTag = .world
    }
    lazy private var secondNone = UIAction(title: TagType.none.rawValue) { _ in
        self.memoVM.secondTag = .none
    }
    
    lazy private var thirdPolitics = UIAction(title: TagType.politics.rawValue) { _ in
        self.memoVM.thirdTag = .politics
    }
    lazy private var thirdEconomics = UIAction(title: TagType.economy.rawValue) { _ in
        self.memoVM.thirdTag = .economy
    }
    lazy private var thirdArt = UIAction(title: TagType.art.rawValue) { _ in
        self.memoVM.thirdTag = .art
    }
    lazy private var thirdEntertainment = UIAction(title: TagType.entertainment.rawValue) { _ in
        self.memoVM.thirdTag = .entertainment
    }
    lazy private var thirdScience = UIAction(title: TagType.science.rawValue) { _ in
        self.memoVM.thirdTag = .science
    }
    lazy private var thirdTechnology = UIAction(title: TagType.technology.rawValue) { _ in
        self.memoVM.thirdTag = .technology
    }
    lazy private var thirdHealth = UIAction(title: TagType.health.rawValue) { _ in
        self.memoVM.thirdTag = .health
    }
    lazy private var thirdLifestyle = UIAction(title: TagType.lifestyle.rawValue) { _ in
        self.memoVM.thirdTag = .lifestyle
    }
    lazy private var thirdSports = UIAction(title: TagType.sports.rawValue) { _ in
        self.memoVM.thirdTag = .sports
    }
    lazy private var thirdWorld = UIAction(title: TagType.world.rawValue) { _ in
        self.memoVM.thirdTag = .world
    }
    lazy private var thirdNone = UIAction(title: TagType.none.rawValue) { _ in
        self.memoVM.thirdTag = .none
    }
    
    lazy private var saveBarButton: CustomBarButtonItem = {
        let button = CustomBarButtonItem(type: .saveRealmObject)
        button.target = self
        button.action = #selector(saveButtonTapped)
        return button
    }()
    
    let memoVM = MemoViewModel()
    
    //MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()

        memoVM.journalTableToBeSaved.bind { newMemo in
            self.memoVM.handleTag()
        }
        
        memoVM.tagTableToBeSaved.bind { newTags in
            self.memoVM.saveJournalToRealm()
        }
        
        memoVM.isJournalMadeFromNaver.bind { value in
            if value {
                //저장 후 설정
                self.resetInputFieldsAndDismiss()
                print("About to send notification naver from memoVC")
                
                //Notification 보내기
                NotificationCenter.default.post(name: .journalSavedInMemoVCFromNaver, object: nil, userInfo: [NotificationUserInfoName.realmBookMarkedNewsLinkToBeSaved: self.memoVM.retrieveBookMarkedNewsWithJournalLink()])
            }
        }
        
        memoVM.isJournalMadeFromMediaStack.bind { value in
            if value {
                //저장 후 설정
                self.resetInputFieldsAndDismiss()
                print("About to send notification mediastack from memoVC")
                
                //Notification 보내기
                NotificationCenter.default.post(name: .journalSavedInMemoVCFromMediaStack, object: nil, userInfo: [NotificationUserInfoName.realmBookMarkedNewsLinkToBeSaved: self.memoVM.retrieveBookMarkedNewsWithJournalLink()])
            }
        }
        
        memoVM.isJournalMadeFromNewsAPI.bind { value in
            if value {
                //저장 후 설정
                self.resetInputFieldsAndDismiss()
                print("About to send notification newsapi from memoVC")
                
                //Notification 보내기
                NotificationCenter.default.post(name: .journalSavedInMemoVCFromNewsAPI, object: nil, userInfo: [NotificationUserInfoName.realmBookMarkedNewsLinkToBeSaved: self.memoVM.retrieveBookMarkedNewsWithJournalLink()])
            }
        }
        
        memoVM.memoErrorMessage.bind { message in
            //에러 메시지 보여주기
            self.showErrorToastMessage(message: message)
        }
        
        memoVM.memoSuccessMessage.bind { message in
            self.showConfirmToastMessage(message: message)
        }
        
        //UserDefaults 내 임시 메모 확인, 존재하면 textView로 가져오기
        checkUserDefaultsAndRealm()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //제목 입력값 존재: 임시 저장
        if let text = titleTextField.text, !text.isEmpty {
            do {
                try self.memoVM.saveTempTitleToUserDefaults(text)
            } catch {
                memoVM.memoErrorMessage.value = MemoSetupValues.savingTempTitleFailed
            }
        }
        
        //memo 입력값 존재: 임시 저장
        if let text = contentTextView.text, !text.isEmpty, !MemoSetupValues.textViewPlaceholders.contains(text) {
            do {
                try self.memoVM.saveTempMemoToUserDefaults(text)
            } catch {
                memoVM.memoErrorMessage.value = MemoSetupValues.savingTempMemoFailed
            }
        }
        
        //backbutton 활성화하기 알림
        NotificationCenter.default.post(name: .memoClosed, object: nil)
    }
    
    override func configureViews() {
        super.configureViews()
        
        navigationItem.rightBarButtonItem = saveBarButton
        
        view.addSubview(titleTextField)
        titleTextField.delegate = self
        
        view.addSubview(firstTagButton)
        view.addSubview(secondTagButton)
        view.addSubview(thirdTagButton)
        
        view.addSubview(contentTextView)
        contentTextView.delegate = self
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.directionalHorizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(Constant.Frame.memoTitleTextFieldInset)
            make.height.equalTo(titleTextField.snp.width).multipliedBy(Constant.Frame.memoTitleTextFieldHeightMultiply)
        }
        
        firstTagButton.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(Constant.Frame.memoTagButtonTopOffset)
            make.leading.equalTo(titleTextField.snp.leading)
            make.width.equalTo(titleTextField.snp.width).multipliedBy(Constant.Frame.memoTagButtonWidthMultiply)
            make.height.equalTo(firstTagButton.snp.width).multipliedBy(Constant.Frame.memoTagButtonHeightMultiply)
        }
        
        secondTagButton.snp.makeConstraints { make in
            make.size.top.equalTo(firstTagButton)
            make.leading.equalTo(firstTagButton.snp.trailing).offset(Constant.Frame.memoTagButtonLeadingOffset)
        }
        
        thirdTagButton.snp.makeConstraints { make in
            make.size.top.equalTo(firstTagButton)
            make.leading.equalTo(secondTagButton.snp.trailing).offset(Constant.Frame.memoTagButtonLeadingOffset)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(firstTagButton.snp.bottom).offset(Constant.Frame.memoTextViewTopOffset)
            make.directionalHorizontalEdges.equalTo(titleTextField.snp.directionalHorizontalEdges)
            make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
        }
    }
    
    private func resetInputFieldsAndDismiss() {
        titleTextField.text = nil
        contentTextView.text = nil
        self.dismiss(animated: true)
    }
    
    //MARK: - API
    
    private func checkUserDefaultsAndRealm() {
        //UserDefaults에 해당 제목 존재: textField에 나타내기
        do {
            let tempTitle = try memoVM.retrieveTempTitleFromUserDefaults()
            titleTextField.text = tempTitle
        } catch MemoError.noTempTitleForBookMarkedNews {
            do {
                let title = try memoVM.retrieveMemoTitle()
                self.titleTextField.text =  title
            } catch MemoError.noBookMarkedNewsToRetrieve {
                //bookmarkedNews 접근 불가
                alertToPopRoot(title: MemoError.noBookMarkedNewsToRetrieve.alertTitle, message: MemoError.noBookMarkedNewsToRetrieve.alertMessage)
            } catch {
                //title 존재하지 않음
            }
        } catch MemoError.noNewsToRetrieve {
            alertToPop(title: MemoError.noNewsToRetrieve.alertTitle, message: MemoError.noNewsToRetrieve.alertMessage)
        } catch {
            //MemoError.noTempTitleForNews
            //있어도 그만, 없어도 그만
        }
            
        //UserDefaults에 해당 메모 존재: textView 나타내기
        do {
            let tempMemo = try memoVM.retrieveTempMemoFromUserDefaults()
            contentTextView.text = tempMemo
            contentTextView.showMemo()
        } catch MemoError.noTempJournalForNews {
            //placeholder 설정하기
            self.contentTextView.setInitialPlaceholder()
        } catch MemoError.noTempJournalForBookMarkedNews {
            //기존 memo 설정, textField 및 textView에 내용 채우기
            do {
                let content = try memoVM.retrieveJournalContent()
                self.contentTextView.text = content
                self.contentTextView.showMemo()
            } catch MemoError.noBookMarkedNewsToRetrieve {
                //Bookmarked news에 접근 불가
                alertToPopRoot(title: MemoError.noBookMarkedNewsToRetrieve.alertTitle, message: MemoError.noBookMarkedNewsToRetrieve.alertMessage)
            } catch {
                //contents 존재하지 않음
            }
        } catch {
            //뉴스 데이터 존재하지 않음
            alertToPop(title: MemoError.noNewsToRetrieve.alertTitle, message: MemoError.noNewsToRetrieve.alertMessage)
        }
        
        //tag realm에 존재하는지 확인
        do {
            let tagTable = try memoVM.retrieveTagTable()
            setupSavedFirstTagButton(tagTable.firstTag)
            setupSavedSecondTagButton(tagTable.secondTag)
            setupSavedThirdTagButton(tagTable.thirdTag)
        } catch MemoError.noBookMarkedNewsToRetrieve {
            alertToPopRoot(title: MemoError.noBookMarkedNewsToRetrieve.alertTitle, message: MemoError.noBookMarkedNewsToRetrieve.alertMessage)
        } catch MemoError.noJournalToRetrieve {
            //저장된 Journal 없음
            configureFirstTagButton()
            configureSecondTagButton()
            configureThirdTagButton()
        } catch {
            //저장된 tag 없음
            configureFirstTagButton()
            configureSecondTagButton()
            configureThirdTagButton()
        }
        
    }
    
    //MARK: - Handlers
    
    @objc func saveButtonTapped() {
        
        //realm 위치 확인 목적
        memoVM.checkRealmSchemaAndPath()
        
        guard let title = self.titleTextField.text, !title.isEmpty else {
            //제목 빈칸: 빈칸 허용하지 않는 toastMessage 보여주기
            showErrorToastMessage(message: MemoSetupValues.textFieldPlaceholder)
            return
        }
        guard let content = self.contentTextView.text, !content.isEmpty, !MemoSetupValues.textViewPlaceholders.contains(content) else {
            //메모 placeholder만 존재하는 경우 허용하지 않기: toastMessage 보여주기
            showErrorToastMessage(message: MemoSetupValues.journalCannotBeSavedDueToNoContent)
            return
        }
        
        do {
            try memoVM.handleMemo(title: title, content: content)
        } catch {
            //realm에 메모 존재하지 않는 경우
            memoVM.memoErrorMessage.value = MemoError.noJournalToRetrieve.alertMessage
        }
       
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "Memo-01",
            AnalyticsParameterItemName: "MemoSaveButton",
            AnalyticsParameterContentType: "saveButtonTapped"
        ])
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "Memo-02",
            AnalyticsParameterItemName: "MemoViewTapToDismissKeyboard",
            AnalyticsParameterContentType: "viewTappedToDismissKeyboard"
        ])
        
    }
    
}

//MARK: - Extension for TextField Delegate

extension MemoViewController: UITextFieldDelegate {
    
    //엔터 키 입력
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "Memo-03",
            AnalyticsParameterItemName: "MemoTextViewEnterKey",
            AnalyticsParameterContentType: "textViewEnterKeyTapped"
        ])
        
        return true
    }
    
}

//MARK: - Extension for TextView Delegate

extension MemoViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        //placeholder 설정된 경우: 제거 및 입력 시작
        if MemoSetupValues.textViewPlaceholders.contains(contentTextView.text) {
            contentTextView.removePlaceholder()
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "Memo-04",
            AnalyticsParameterItemName: "MemoTextViewStartEditing",
            AnalyticsParameterContentType: "textViewStartEdit"
        ])
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //빈칸: placeholder 설정
        if contentTextView.text.isEmpty {
            contentTextView.setInitialPlaceholder()
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "Memo-05",
            AnalyticsParameterItemName: "MemoTextViewEndEditing",
            AnalyticsParameterContentType: "textViewEndEdit"
        ])
    }

}
    
//MARK: - Extension for SettingUp Menus

extension MemoViewController {
    
    private func configureFirstTagButton() {
        firstTagButton.menu = UIMenu(title: "", options: .singleSelection, children: [firstNone, firstPolitics, firstEconomics, firstArt, firstEntertainment, firstScience, firstTechnology, firstHealth, firstLifestyle, firstSports, firstWorld])
    }
    
    private func configureSecondTagButton() {
        secondTagButton.menu = UIMenu(title: "", options: .singleSelection, children: [secondNone, secondPolitics, secondEconomics, secondArt, secondEntertainment, secondScience, secondTechnology, secondHealth, secondLifestyle, secondSports, secondWorld])
    }
    
    private func configureThirdTagButton() {
        thirdTagButton.menu = UIMenu(title: "", options: .singleSelection, children: [thirdNone, thirdPolitics, thirdEconomics, thirdArt, thirdEntertainment, thirdScience, thirdTechnology, thirdHealth, thirdLifestyle, thirdSports, thirdWorld])
    }
    
    private func setupSavedFirstTagButton(_ savedFirst: TagType) {
        
        var menu = [firstNone, firstPolitics, firstEconomics, firstArt, firstEntertainment, firstScience, firstTechnology, firstHealth, firstLifestyle, firstSports, firstWorld]
        
        switch savedFirst {
        case .whole:
            break
        case .politics:
            menu.swapAt(0, 1)
        case .economy:
            menu.swapAt(0, 2)
        case .art:
            menu.swapAt(0, 3)
        case .entertainment:
            menu.swapAt(0, 4)
        case .science:
            menu.swapAt(0, 5)
        case .technology:
            menu.swapAt(0, 6)
        case .health:
            menu.swapAt(0, 7)
        case .lifestyle:
            menu.swapAt(0, 8)
        case .sports:
            menu.swapAt(0, 9)
        case .world:
            menu.swapAt(0, 10)
        case .none:
            break
        }
        firstTagButton.menu = UIMenu(title: "", options: .singleSelection, children: menu)
    }

    private func setupSavedSecondTagButton(_ savedSecond: TagType) {
        var menu = [secondNone, secondPolitics, secondEconomics, secondArt, secondEntertainment, secondScience, secondTechnology, secondHealth, secondLifestyle, secondSports, secondWorld]
        
        switch savedSecond {
        case .whole:
            break
        case .politics:
            menu.swapAt(0, 1)
        case .economy:
            menu.swapAt(0, 2)
        case .art:
            menu.swapAt(0, 3)
        case .entertainment:
            menu.swapAt(0, 4)
        case .science:
            menu.swapAt(0, 5)
        case .technology:
            menu.swapAt(0, 6)
        case .health:
            menu.swapAt(0, 7)
        case .lifestyle:
            menu.swapAt(0, 8)
        case .sports:
            menu.swapAt(0, 9)
        case .world:
            menu.swapAt(0, 10)
        case .none:
            break
        }
        secondTagButton.menu = UIMenu(title: "", options: .singleSelection, children: menu)
    }

    private func setupSavedThirdTagButton(_ savedThird: TagType) {
        var menu = [thirdNone, thirdPolitics, thirdEconomics, thirdArt, thirdEntertainment, thirdScience, thirdTechnology, thirdHealth, thirdLifestyle, thirdSports, thirdWorld]
        
        switch savedThird {
        case .whole:
            break
        case .politics:
            menu.swapAt(0, 1)
        case .economy:
            menu.swapAt(0, 2)
        case .art:
            menu.swapAt(0, 3)
        case .entertainment:
            menu.swapAt(0, 4)
        case .science:
            menu.swapAt(0, 5)
        case .technology:
            menu.swapAt(0, 6)
        case .health:
            menu.swapAt(0, 7)
        case .lifestyle:
            menu.swapAt(0, 8)
        case .sports:
            menu.swapAt(0, 9)
        case .world:
            menu.swapAt(0, 10)
        case .none:
            break
        }
        thirdTagButton.menu = UIMenu(title: "", options: .singleSelection, children: menu)
    }
    
}
