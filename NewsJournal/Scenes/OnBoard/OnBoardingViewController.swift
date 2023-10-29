//
//  OnBoardingViewController.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/10.
//

import UIKit

final class OnBoardingViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let pageControl: UIPageControl = {
        let control = UIPageControl(frame: .zero)
        control.numberOfPages = OnBoardingSetupValues.pageNum
        control.currentPage = OnBoardingSetupValues.startPage
        control.isUserInteractionEnabled = false
        return control
    }()
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.isPagingEnabled = true
        view.backgroundColor = .orange
        return view
    }()
    
    let onBoardingVM = OnBoardingViewModel()
    
    //MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        onBoardingVM.willNotShowOnBoardingAgain.bind { value in
            //true/false 따라 userDefaults 값 변경
            if value {
                
            } else {
                
            }
        }
        
    }
    
    override func configureViews() {
        super.configureViews()
        
        view.backgroundColor = .green
        
        view.addSubview(scrollView)
        scrollView.delegate = self
        
        view.addSubview(pageControl)
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        let width = view.safeAreaLayoutGuide.layoutFrame.width
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        scrollView.contentSize = CGSize(width: CGFloat(OnBoardingSetupValues.pageNum) * width, height: 0)
        
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(100)
            make.width.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(pageControl.snp.width).multipliedBy(0.2)
        }
        
        setupEachPage(width: width)
    }
    
    private func setupEachPage(width: CGFloat) {
        
        let height = view.safeAreaLayoutGuide.layoutFrame.height
        
        for i in 0..<OnBoardingSetupValues.pageNum {
            
            //닫기 버튼
            let exitButton: UIButton = UIButton(frame: CGRect(x: CGFloat(i) * width + width * 0.8, y: width * 0.1, width: width * 0.1, height: width * 0.1))
            exitButton.backgroundColor = .red
            exitButton.setImage(UIImage(systemName: Constant.ImageString.xmarkCircleImageString), for: .normal)
            exitButton.tintColor = .white
            exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
            
            //중앙 설명 이미지
            let centerImageView: UIImageView = UIImageView(frame: CGRect(x: CGFloat(i) * width + width * 0.25, y: height/2 - width/4, width: width * 0.5, height: width * 0.5))
            centerImageView.contentMode = .scaleAspectFit
            centerImageView.backgroundColor = .systemMint
            
            //하단 onboarding 다시 볼 지 여부 체크 버튼
            let notShowingOnBoardingAgainCheckButton: UIButton = UIButton(frame: CGRect(x: CGFloat(i) * width + width * 0.25, y: height * 0.9, width: width * 0.25, height: width * 0.1))
            notShowingOnBoardingAgainCheckButton.configuration = setupCheckButtonConfiguration()
            notShowingOnBoardingAgainCheckButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
            
            scrollView.addSubview(exitButton)
            scrollView.addSubview(centerImageView)
            scrollView.addSubview(notShowingOnBoardingAgainCheckButton)
        }

    }
    
    private func setupCheckButtonConfiguration() -> UIButton.Configuration {
        var buttonConfiguration = UIButton.Configuration.filled()
        
        var titleAttribute = AttributedString.init("다음부터 안볼래요")
        titleAttribute.font = .boldSystemFont(ofSize: 15)
        buttonConfiguration.attributedTitle = titleAttribute
        
        buttonConfiguration.baseForegroundColor = Constant.Color.tagButtonText
        buttonConfiguration.baseBackgroundColor = Constant.Color.mainRed
        
        buttonConfiguration.image = UIImage(systemName: Constant.ImageString.deselectedCheckMarkImageString)?.withTintColor(Constant.Color.tagButtonText)
        return buttonConfiguration
    }
    
    //MARK: - Handlers
    
    @objc private func exitButtonTapped() {
        //단순 닫는 것인지, check button tap된 상황인지 확인
        print(#function)
    }
    
    @objc private func checkButtonTapped(_ sender: UIButton) {
        onBoardingVM.willNotShowOnBoardingAgain.value.toggle()
        
        if onBoardingVM.isChecked() {
            sender.imageView?.image = UIImage(systemName: Constant.ImageString.selectedCheckMarkImageString)?.withTintColor(Constant.Color.tagButtonText)
        } else {
            sender.imageView?.image = UIImage(systemName: Constant.ImageString.deselectedCheckMarkImageString)?.withTintColor(Constant.Color.tagButtonText)
        }
        
    }
    
}

//MARK: - Extension for ScrollView Delegate

extension OnBoardingViewController: UIScrollViewDelegate {
    
    
    
}
