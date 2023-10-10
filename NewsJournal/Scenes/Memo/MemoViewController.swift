//
//  MemoViewController.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import UIKit

final class MemoViewController: BaseViewController {
    
    //MARK: - Properties
    
    let titleTextField = CustomTextField()
    let contentTextView = CustomTextView()
    
    lazy var firstTagButton = CustomPullDownButton()
    lazy var secondTagButton = CustomPullDownButton()
    lazy var thirdTagButton = CustomPullDownButton()
    
    lazy var saveBarButton: CustomBarButtonItem = {
        let button = CustomBarButtonItem(type: .saveRealmObject)
        button.target = self
        button.action = #selector(saveButtonTapped)
        return button
    }()
    
    let memoVM = MemoViewModel()
    
    //MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureFirstTagButton()
        configureSecondTagButton()
        configureThirdTagButton()
        
        memoVM.memoTableToBeSaved.bind { newMemo in
            self.memoVM.handleTag()
        }
        
        memoVM.tagTableToBeSaved.bind { newTags in
            self.memoVM.saveJournalToRealm()
        }
        
        memoVM.isJournalMade.bind { value in
            if value {
                //저장 후 설정
                self.titleTextField.text = nil
                self.contentTextView.text = nil
     
                self.dismiss(animated: true)
                
                //Notification 보내기
                NotificationCenter.default.post(name: .realmSaved, object: nil)
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
        checkUserDefaults()
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
        if let text = contentTextView.text, !text.isEmpty, text != MemoSetupValues.textViewPlaceholder {
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
            make.top.directionalHorizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(Constant.Frame.memoTitleTextFieldInset)
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
    
    //MARK: - API
    
    //작업 코드 아예 viewModel에서 처리하기
    //결과 string만 받아서 vc에서 하기
    private func checkUserDefaults() {
        //UserDefaults에 해당 제목 존재: textField에 나타내기
        do {
            let tempTitle = try memoVM.retrieveTempTitleFromUserDefaults()
            titleTextField.text = tempTitle
        } catch MemoError.noTempTitleForNews {
            //있어도 그만, 없어도 그만
        } catch MemoError.noTempTitleForJournal {
            do {
                let title = try memoVM.retrieveMemoTitle()
                self.titleTextField.text =  title
            } catch {
                //journal 접근 불가
                alertToPopRoot(title: MemoError.noJournalToRetrieve.alertTitle, message: MemoError.noJournalToRetrieve.alertMessage)
            }
        }
        catch {
            alertToPop(title: MemoError.noNewsToRetrieve.alertTitle, message: MemoError.noNewsToRetrieve.alertMessage)
        }
            
        //UserDefaults에 해당 메모 존재: textView 나타내기
        do {
            let tempMemo = try memoVM.retrieveTempMemoFromUserDefaults()
            contentTextView.text = tempMemo
            contentTextView.showMemo()
        } catch MemoError.noTempMemoForNews {
            //placeholder 설정하기
            self.contentTextView.setInitialPlaceholder()
        } catch MemoError.noTempMemoForJournal {
            //기존 memo 설정, textField 및 textView에 내용 채우기
            do {
                let content = try memoVM.retrieveMemoContent()
                self.contentTextView.text = content
                self.contentTextView.showMemo()
            } catch {
                //journal (realm) 접근 불가
                alertToPopRoot(title: MemoError.noJournalToRetrieve.alertTitle, message: MemoError.noJournalToRetrieve.alertMessage)
            }
        } catch {
            //뉴스 데이터 존재하지 않음
            alertToPop(title: MemoError.noNewsToRetrieve.alertTitle, message: MemoError.noNewsToRetrieve.alertMessage)
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
        guard let content = self.contentTextView.text, !content.isEmpty, content != MemoSetupValues.textViewPlaceholder else {
            //메모 placeholder만 존재하는 경우 허용하지 않기: toastMessage 보여주기
            showErrorToastMessage(message: MemoSetupValues.textViewPlaceholder)
            return
        }
        
        do {
            try memoVM.handleMemo(title: title, content: content)
        } catch {
            //realm에 메모 존재하지 않는 경우
            memoVM.memoErrorMessage.value = MemoError.noMemoToRetrieve.alertMessage
        }
       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

//MARK: - Extension for TextField Delegate

extension MemoViewController: UITextFieldDelegate {
    
    //엔터 키 입력
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { return true }
    
}

//MARK: - Extension for TextView Delegate

extension MemoViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        //placeholder 설정된 경우: 제거 및 입력 시작
        if contentTextView.text == MemoSetupValues.textViewPlaceholder {
            contentTextView.removePlaceholder()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //빈칸: placeholder 설정
        if contentTextView.text.isEmpty {
            contentTextView.setInitialPlaceholder()
        }
    }

}
    
//MARK: - Extension for SettingUp Menus

extension MemoViewController {
    
    private func configureFirstTagButton() {
        let politics = UIAction(title: TagType.politics.rawValue) { _ in
            self.memoVM.firstTag = .politics
        }
        let economics = UIAction(title: TagType.economy.rawValue) { _ in
            self.memoVM.firstTag = .economy
        }
        let art = UIAction(title: TagType.art.rawValue) { _ in
            self.memoVM.firstTag = .art
        }
        let entertainment = UIAction(title: TagType.entertainment.rawValue) { _ in
            self.memoVM.firstTag = .entertainment
        }
        let science = UIAction(title: TagType.science.rawValue) { _ in
            self.memoVM.firstTag = .science
        }
        let technology = UIAction(title: TagType.technology.rawValue) { _ in
            self.memoVM.firstTag = .technology
        }
        let health = UIAction(title: TagType.health.rawValue) { _ in
            self.memoVM.firstTag = .health
        }
        let lifestyle = UIAction(title: TagType.lifestyle.rawValue) { _ in
            self.memoVM.firstTag = .lifestyle
        }
        let sports = UIAction(title: TagType.sports.rawValue) { _ in
            self.memoVM.firstTag = .sports
        }
        let world = UIAction(title: TagType.world.rawValue) { _ in
            self.memoVM.firstTag = .world
        }
        let none = UIAction(title: TagType.none.rawValue) { _ in
            self.memoVM.firstTag = .none
        }
        firstTagButton.menu = UIMenu(title: "", options: .singleSelection, children: [none, politics, economics, art, entertainment, science, technology, health, lifestyle, sports, world])
    }
    
    private func configureSecondTagButton() {
        let politics = UIAction(title: TagType.politics.rawValue) { _ in
            self.memoVM.secondTag = .politics
        }
        let economics = UIAction(title: TagType.economy.rawValue) { _ in
            self.memoVM.secondTag = .economy
        }
        let art = UIAction(title: TagType.art.rawValue) { _ in
            self.memoVM.secondTag = .art
        }
        let entertainment = UIAction(title: TagType.entertainment.rawValue) { _ in
            self.memoVM.secondTag = .entertainment
        }
        let science = UIAction(title: TagType.science.rawValue) { _ in
            self.memoVM.secondTag = .science
        }
        let technology = UIAction(title: TagType.technology.rawValue) { _ in
            self.memoVM.secondTag = .technology
        }
        let health = UIAction(title: TagType.health.rawValue) { _ in
            self.memoVM.secondTag = .health
        }
        let lifestyle = UIAction(title: TagType.lifestyle.rawValue) { _ in
            self.memoVM.secondTag = .lifestyle
        }
        let sports = UIAction(title: TagType.sports.rawValue) { _ in
            self.memoVM.secondTag = .sports
        }
        let world = UIAction(title: TagType.world.rawValue) { _ in
            self.memoVM.secondTag = .world
        }
        let none = UIAction(title: TagType.none.rawValue) { _ in
            self.memoVM.secondTag = .none
        }
        secondTagButton.menu = UIMenu(title: "", options: .singleSelection, children: [none, politics, economics, art, entertainment, science, technology, health, lifestyle, sports, world])
    }
    
    private func configureThirdTagButton() {
        let politics = UIAction(title: TagType.politics.rawValue) { _ in
            self.memoVM.thirdTag = .politics
        }
        let economics = UIAction(title: TagType.economy.rawValue) { _ in
            self.memoVM.thirdTag = .economy
        }
        let art = UIAction(title: TagType.art.rawValue) { _ in
            self.memoVM.thirdTag = .art
        }
        let entertainment = UIAction(title: TagType.entertainment.rawValue) { _ in
            self.memoVM.thirdTag = .entertainment
        }
        let science = UIAction(title: TagType.science.rawValue) { _ in
            self.memoVM.thirdTag = .science
        }
        let technology = UIAction(title: TagType.technology.rawValue) { _ in
            self.memoVM.thirdTag = .technology
        }
        let health = UIAction(title: TagType.health.rawValue) { _ in
            self.memoVM.thirdTag = .health
        }
        let lifestyle = UIAction(title: TagType.lifestyle.rawValue) { _ in
            self.memoVM.thirdTag = .lifestyle
        }
        let sports = UIAction(title: TagType.sports.rawValue) { _ in
            self.memoVM.thirdTag = .sports
        }
        let world = UIAction(title: TagType.world.rawValue) { _ in
            self.memoVM.thirdTag = .world
        }
        let none = UIAction(title: TagType.none.rawValue) { _ in
            self.memoVM.thirdTag = .none
        }
        thirdTagButton.menu = UIMenu(title: "", options: .singleSelection, children: [none, politics, economics, art, entertainment, science, technology, health, lifestyle, sports, world])
    }
    
}
