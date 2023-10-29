//
//  DefaultMediaStackNewsCell.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/20.
//

import UIKit

import Kingfisher
import SkeletonView

final class DefaultMediaStackNewsCell: BaseCollectionViewCell {
    
    //MARK: - Properties
    
    lazy private var newsImageView = CustomNewsImageView(frame: .zero)
    private let newsTitleLabel = CustomNewsTitleLabel(frame: .zero)
    private let dateLabel = CustomNewsDateLabel(frame: .zero)
    private let pressLabel = CustomNewsPressLabel(frame: .zero)
    
    lazy private var journalWrittenImageView = CustomJournalWrittenImageView(frame: .zero)
    lazy var bookMarkButton = CustomBookMarkButton()
    
    let defaultMediaNewsCellVM = DefaultMediaStackNewsCellViewModel()
    
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
        
        defaultMediaNewsCellVM.news.bind { passedNews in
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
        if defaultMediaNewsCellVM.checkBookMarkedNewsExists(news: news) {
            bookMarkButton.setSelected()
            //Journal 존재 확인
            if defaultMediaNewsCellVM.checkJournalExistsWith(news: news) {
                journalWrittenImageView.showImageView()
            } else {
                journalWrittenImageView.hideImageView()
            }
        } else {
            bookMarkButton.setUnselected()
        }
        
        //1. Disk에 image 존재 확인
        if let imageData = defaultMediaNewsCellVM.checkImageInDocuments(), let image = UIImage(data: imageData) {
            setupLinkView(news: news, image: image)
            return
        }
        
        //2. news에서 imagelink 존재 시 kingfisher 활용 이미지 가져오기
        if let imageURL = news.imageURL, let url = URL(string: imageURL) {
            newsImageView.kf.setImage(with: url) { _ in
                //디스크에 이미지 저장하기
                guard let image = self.newsImageView.image else { return }
                self.defaultMediaNewsCellVM.saveImageIntoDocuments(image: image)
                return
            }
        }

        //3. 존재하지 않으면 cache에 metadata 존재 체크
        if let metaData = defaultMediaNewsCellVM.checkMetadataInMemoryCache() {
            //4-1. 존재하면 loadObject로 image 받아오기
            defaultMediaNewsCellVM.retrieveImageFromLink(metaData: metaData) { image in
                if let image = image {
                    //5-1. image 저장하고 cell 나타내기
                    self.defaultMediaNewsCellVM.saveImageIntoDocuments(image: image)
                    self.setupLinkView(news: news, image: image)
                } else {
                    self.setupInvalidLinkPresentation(news: news)
                }
            }
        } else {
            //4-2. 존재하지 않으면 startFetch하기
            defaultMediaNewsCellVM.fetchMediaNewsMetaData(url: news.urlLink) { result in
                switch result {
                case .success(let data):
                    //5-2-1. metaData 존재: memoryCache에 metadata 저장
                    self.defaultMediaNewsCellVM.saveMetadataIntoMemory(data: data)
                    //6-2-1. loadObject로 image 받아오기
                    self.defaultMediaNewsCellVM.retrieveImageFromLink(metaData: data) { image in
                        if let image = image {
                            //7-2-1. image 저장하고 cell 나타내기
                            self.defaultMediaNewsCellVM.saveImageIntoDocuments(image: image)
                            self.setupLinkView(news: news, image: image)
                        } else {
                            self.setupInvalidLinkPresentation(news: news)
                        }
                    }
                case .failure(_):
                    //5-2-2. metaData 존재 X: default 이미지로 cell 구성하기
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
        self.newsTitleLabel.text = news.title
        self.dateLabel.text = news.pubDate
        self.pressLabel.text = defaultMediaNewsCellVM.mapPressWithNewsLink()
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
