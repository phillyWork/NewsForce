//
//  DefaultNaverNewsCell.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/15.
//

import UIKit

import SkeletonView

final class DefaultNaverNewsCell: BaseCollectionViewCell {
    
    //MARK: - Properties
    
    lazy private var newsImageView = CustomNewsImageView(frame: .zero)
    private let newsTitleLabel = CustomNewsTitleLabel(frame: .zero)
    private let dateLabel = CustomNewsDateLabel(frame: .zero)
    private let pressLabel = CustomNewsPressLabel(frame: .zero)
    
    lazy private var journalWrittenImageView = CustomJournalWrittenImageView(frame: .zero)
    lazy var bookMarkButton = CustomBookMarkButton()
    
    let defaultNaverNewsCellVM = DefaultNaverNewsCellViewModel()
    
    //MARK: - Setup
    
    override func configCell() {
        super.configCell()
        
        isSkeletonable = true
        contentView.isSkeletonable = true
        
        contentView.addSubview(newsImageView)
        contentView.addSubview(newsTitleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(pressLabel)
        contentView.addSubview(bookMarkButton)
        contentView.addSubview(journalWrittenImageView)
        
        defaultNaverNewsCellVM.news.bind { passedNews in
            guard let news = passedNews else { return }
            print("link: ", news.urlLink)
            self.populateWithPassedData(news: news)
        }
    }
    
    override func setupCellComponentsConstraints() {
        super.setupCellComponentsConstraints()
        
        newsImageView.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.snp.centerY)
            make.leading.equalTo(contentView).offset(Constant.Frame.newsImageViewLeadingOffset)
            make.height.equalTo(contentView.snp.height).multipliedBy(Constant.Frame.newsImageViewHeightMultiply)
            make.width.equalTo(newsImageView.snp.height)
        }
        
        bookMarkButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(contentView)
            make.height.equalTo(contentView.snp.height).multipliedBy(Constant.Frame.newsBookMarkButtonHeightMultiply)
            make.width.equalTo(bookMarkButton.snp.height)
        }
        
        newsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(newsImageView.snp.top)
            make.leading.equalTo(newsImageView.snp.trailing).offset(Constant.Frame.newsTitleLeadingOffset)
            make.trailing.equalTo(bookMarkButton.snp.leading).offset(Constant.Frame.newsTitleTrailingOffset)
            make.height.equalTo(newsImageView.snp.height).multipliedBy(Constant.Frame.newsTitleHeightMultiply)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(newsTitleLabel.snp.bottom).offset(Constant.Frame.newsDateTopOffset)
            make.directionalHorizontalEdges.equalTo(newsTitleLabel)
        }
        
        pressLabel.snp.makeConstraints { make in
            make.bottom.equalTo(contentView).inset(Constant.Frame.newsPressBottomInset)
            make.trailing.equalTo(bookMarkButton.snp.trailing).offset(Constant.Frame.newsPressTrailingOffset)
            make.leading.equalTo(newsTitleLabel.snp.leading)
        }
        
        journalWrittenImageView.snp.makeConstraints { make in
            make.trailing.equalTo(bookMarkButton.snp.leading)
            make.centerY.equalTo(bookMarkButton.snp.centerY)
            make.size.equalTo(bookMarkButton.snp.size)
        }
    }
    
    private func populateWithPassedData(news: DTONews) {
        
        activateSkeletonAnimation()
                
        //Bookmarked 여부 확인
        if defaultNaverNewsCellVM.checkBookMarkedNewsExists(news: news) {
            bookMarkButton.setSelected()
            //Journal 존재 확인
            if defaultNaverNewsCellVM.checkJournalExistsWith(news: news) {
                journalWrittenImageView.showImageView()
            } else {
                journalWrittenImageView.hideImageView()
            }
        } else {
            bookMarkButton.setUnselected()
        }
        
        //1. Disk에 image 존재 확인
        if let imageData = defaultNaverNewsCellVM.checkImageInDocuments(), let image = UIImage(data: imageData) {
            setupLinkView(news: news, image: image)
            return
        }
        
        //2. 존재하지 않으면 cache에 metadata 존재 체크
        if let metaData = defaultNaverNewsCellVM.checkMetadataInMemoryCache() {
            //3-1. 존재하면 loadObject로 image 받아오기
            defaultNaverNewsCellVM.retrieveImageFromLink(metaData: metaData) { image in
                if let image = image {
                    //4-1. image 저장하고 cell 나타내기
                    self.defaultNaverNewsCellVM.saveImageIntoDocuments(image: image)
                    self.setupLinkView(news: news, image: image)
                } else {
                    self.setupInvalidLinkPresentation(news: news)
                }
            }
        } else {
            //3-2. 존재하지 않으면 startFetch하기
            defaultNaverNewsCellVM.fetchNaverNewsMetaData(url: news.urlLink) { result in
                switch result {
                case .success(let data):
                    //4-2-1. metaData 존재: memoryCache에 metadata 저장
                    self.defaultNaverNewsCellVM.saveMetadataIntoMemory(data: data)
                    //5-2-1. loadObject로 image 받아오기
                    self.defaultNaverNewsCellVM.retrieveImageFromLink(metaData: data) { image in
                        if let image = image {
                            //6-2-1. image 저장하고 cell 나타내기
                            self.defaultNaverNewsCellVM.saveImageIntoDocuments(image: image)
                            self.setupLinkView(news: news, image: image)
                        } else {
                            self.setupInvalidLinkPresentation(news: news)
                        }
                    }
                case .failure(_):
                    //4-2-2. metaData 존재 X: default 이미지로 cell 구성하기
                    self.setupInvalidLinkPresentation(news: news)
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        newsImageView.image = nil
        newsTitleLabel.text = nil
        dateLabel.text = nil
        pressLabel.text = nil
        
        //bookmark버튼: 선택 안된 것이 default
        bookMarkButton.setUnselected()
        
        //journalImage: 안보이는 것 default
        journalWrittenImageView.hideImageView()
    }
    
    private func setupLinkView(news: DTONews, image: UIImage) {
        DispatchQueue.main.asyncAfter(deadline: Constant.TimeDelay.skeletonDispatchAsyncAfter) {
            self.hideSkeleton()
            self.newsImageView.image = image
            self.setupBasicNewsData(news: news)
        }
    }
    
    private func setupInvalidLinkPresentation(news: DTONews) {
        DispatchQueue.main.asyncAfter(deadline: Constant.TimeDelay.skeletonDispatchAsyncAfter) {
            self.hideSkeleton()
            self.newsImageView.image = UIImage(named: Constant.ImageString.notAvailable)
            self.setupBasicNewsData(news: news)
        }
    }
    
    private func setupBasicNewsData(news: DTONews) {
        newsTitleLabel.text = news.title
        dateLabel.text = news.pubDate
        pressLabel.text = defaultNaverNewsCellVM.mapPressWithNewsLink()
    }
    
    private func activateSkeletonAnimation() {
        showAnimatedGradientSkeleton()
    }
    
    //MARK: - API
    
    func showJournalWrittenImage() {
        journalWrittenImageView.showImageView()
    }
    
    func hideJournalWrittenImage() {
        journalWrittenImageView.hideImageView()
    }
    
}
