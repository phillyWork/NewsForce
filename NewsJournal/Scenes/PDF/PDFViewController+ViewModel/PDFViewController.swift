//
//  PDFViewController.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/01.
//

import UIKit
import PDFKit

final class PDFViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let pdfView = PDFView()
    
    lazy private var backButton: CustomBarButtonItem = {
        let button = CustomBarButtonItem(type: .backToList)
        button.target = self
        button.action = #selector(backButtonTapped)
        return button
    }()
    
    //to show current PDF page
    private var pageInfoContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constant.Frame.pdfPageInfoContainerCornerRadius
        view.backgroundColor = Constant.Color.linkDateShadowText
        return view
    }()
    
    private var currentPageLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.pdfPageInfoLabel
        label.textColor = Constant.Color.whiteBackground
        return label
    }()
    
    private var timer: Timer?
    
    let pdfVM = PDFViewModel()
    
    //MARK: - Set up
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pdfVM.pdfSucceedMessage.bind { message in
            self.showConfirmToastMessage(message: message)
        }
        
        populatePreview()
        
        //notification for pdf
        NotificationCenter.default.addObserver(self, selector: #selector(handlePageChange), name: .PDFViewPageChanged, object: nil)
    }
        
    override func configureViews() {
        super.configureViews()
        
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: PDFCreatorSetupValues.shareButtonImageString), style: .plain, target: self, action: #selector(sharedButtonTapped))
        
        view.addSubview(pdfView)
        view.addSubview(pageInfoContainer)
        pageInfoContainer.addSubview(currentPageLabel)
        pageInfoContainer.isHidden = true
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        pdfView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        pageInfoContainer.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).offset(Constant.Frame.pdfPageInfoContainerOffset)
        }
        
        currentPageLabel.snp.makeConstraints { make in
            make.top.equalTo(pageInfoContainer.snp.top).offset(Constant.Frame.pdfCurrentPageLabelTopOffset)
            make.directionalHorizontalEdges.equalTo(pageInfoContainer.snp.directionalHorizontalEdges).inset(Constant.Frame.pdfCurrentPageLabelDirectionalHorizontalOffset)
            make.bottom.equalTo(pageInfoContainer.snp.bottom).offset(Constant.Frame.pdfCurrentPageLabelBottomOffset)
        }
    
    }
    
    //MARK: - API
    
    private func populatePreview() {
        
        guard let data = pdfVM.documentData else { return }
        
        self.pdfView.autoScales = true   //set pdfDocument into pdfView
        self.pdfView.displayMode = .singlePageContinuous
        self.pdfView.displayDirection = .vertical
        self.pdfView.document = PDFDocument(data: data)
        
        pdfVM.pdfSucceedMessage.value = PDFCreatorSetupValues.pdfViewSucceedMessage
    }
    
    
    //MARK: - Handlers
    
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func sharedButtonTapped() {
        
        guard let pdfData = pdfVM.documentData else { return }
        
        //show activityVC to share data
        let activityVC = UIActivityViewController(activityItems: [pdfData], applicationActivities: [])
        
        let excludedActivities = [UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToTwitter, UIActivity.ActivityType.postToFacebook, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.saveToCameraRoll, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.addToReadingList]
        
        activityVC.excludedActivityTypes = excludedActivities
        activityVC.popoverPresentationController?.sourceView = self.view
        
        //when error occurred
        activityVC.completionWithItemsHandler = { (activity, success, items, error) in
            if success {
                self.showConfirmToastMessage(message: PDFCreatorSetupValues.activityShareSuccessMessage)
                self.navigationController?.popViewController(animated: true)
            } else if error != nil {
                self.showErrorToastMessage(message: PDFCreatorSetupValues.activityShareFailureMessage)
            }
        }
        present(activityVC, animated: true)
    }
    
    @objc private func handlePageChange() {
        pageInfoContainer.isHidden = false
        view.bringSubviewToFront(currentPageLabel)
        
        if let currentPage = pdfView.currentPage, let pageIndex = pdfView.document?.index(for: currentPage) {
            
            UIView.animate(withDuration: PDFCreatorSetupValues.showPageInfoDuration) {
                self.pageInfoContainer.alpha = PDFCreatorSetupValues.showPageInfoAlpha
            } completion: { (finished) in
                if finished {
                    self.startTimer()
                }
            }
            currentPageLabel.text = "\(pageIndex + 1) of \(pdfView.document?.pageCount ?? .zero)"
        }
        
    }
    
    //MARK: - Timer
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: PDFCreatorSetupValues.timerStaringDuration, target: self, selector: #selector(whenTimerEnds), userInfo: nil, repeats: false)
    }
    
    @objc private func whenTimerEnds() {
        UIView.animate(withDuration: PDFCreatorSetupValues.timerEndingDuration) {
            self.pageInfoContainer.alpha = PDFCreatorSetupValues.hidePageInfoAlpha
        }
    }
    
    //MARK: - Deinit
    
    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self, name: .PDFViewPageChanged, object: nil)
    }
    
}
