//
//  BookMarkedNewsCell.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/24.
//

import UIKit

final class BookMarkedNewsCell: BaseCollectionViewCell {
    
    lazy private var newsImageView = CustomNewsImageView(frame: .zero)
    private let newsTitleLabel = CustomNewsTitleLabel(frame: .zero)
    private let dateLabel = CustomNewsDateLabel(frame: .zero)
    private let pressLabel = CustomNewsPressLabel(frame: .zero)

    lazy private var journalWrittenImageView = CustomJournalWrittenImageView(frame: .zero)
    lazy var bookMarkButton = CustomBookMarkButton()
    private let checkImage = CustomSelectedCheckImageView(image: UIImage(systemName: Constant.ImageString.checkImageString))
//    private let checkImage = UIImageView(image: UIImage(systemName: Constant.ImageString.checkImageString))
    
    let bookmarkedNewsCellVM = BookMarkedNewsCellViewModel()
    
    //MARK: - Setup
    
    override func configCell() {
        super.configCell()
    
        contentView.addSubview(newsImageView)
        contentView.addSubview(newsTitleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(pressLabel)
        contentView.addSubview(bookMarkButton)
        contentView.addSubview(journalWrittenImageView)
        contentView.addSubview(checkImage)
        
//        checkImage.tintColor = Constant.Color.mainRed
//        checkImage.isHidden = true
        
        bookmarkedNewsCellVM.bookmarkedNews.bind { passedNews in
            guard let news = passedNews else { return }
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
        
        checkImage.snp.makeConstraints { make in
            make.leading.top.equalTo(contentView).offset(Constant.Frame.journalRealmCellCheckImageLeadingTopOffset)
            make.width.equalTo(contentView).multipliedBy(Constant.Frame.journalRealmCellCheckImageSizeMultiply)
            make.height.equalTo(checkImage.snp.width)
        }
    }
    
    private func populateWithPassedData(news: BookMarkedNews) {
        bookMarkButton.setSelected()
        //Journal 존재 확인
        if bookmarkedNewsCellVM.checkJournalExistsWith(news: news) {
            journalWrittenImageView.showImageView()
        } else {
            journalWrittenImageView.hideImageView()
        }
        
        //Disk에 image 존재 확인
        if let imageData = bookmarkedNewsCellVM.checkImageInDocuments(), let image = UIImage(data: imageData) {
            setupLinkView(news: news, image: image)
        } else {
            setupInvalidLinkPresentation(news: news)
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
    
    private func setupLinkView(news: BookMarkedNews, image: UIImage) {
        DispatchQueue.main.async {
            self.newsImageView.image = image
            self.setupBasicNewsData(news: news)
        }
    }
    
    private func setupInvalidLinkPresentation(news: BookMarkedNews) {
        DispatchQueue.main.async {
            self.newsImageView.image = UIImage(named: Constant.ImageString.notAvailable)
            self.setupBasicNewsData(news: news)
        }
    }
    
    private func setupBasicNewsData(news: BookMarkedNews) {
        self.newsTitleLabel.text = news.title
        self.dateLabel.text = news.pubDate
        self.pressLabel.text = bookmarkedNewsCellVM.mapPressWithNewsLink()
    }

    //MARK: - API
    
    func toggleCheckImage() {
        checkImage.isHidden.toggle()
    }
 
    func showJournalWrittenImage() {
        journalWrittenImageView.showImageView()
    }
    
    func hideJournalWrittenImage() {
        journalWrittenImageView.hideImageView()
    }
    
}
