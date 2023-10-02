//
//  NewsLinkPresentationCell.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/02.
//

import UIKit
import LinkPresentation

final class NewsLinkPresentationCell: BaseCollectionViewCell {

    let newsLinkPresentationVM = NewsLinkPresentationViewModel()
        
    override func configCell() {
        super.configCell()
        
        newsLinkPresentationVM.news.bind { news in
            guard let news = news else { return }
            self.populateData(news: news)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    private func populateData(news: News) {
        newsLinkPresentationVM.fetchData(url: news.existingLink) { result in
            switch result {
            case .success(let data):
                self.setupLinkView(metaData: data)
            case .failure(_):
                self.setupInvalidLinkPresentation()
            }
        }
    }
        
    private func setupLinkView(metaData: LPLinkMetadata) {
        DispatchQueue.main.async {
            let linkView = LPLinkView(metadata: metaData)
            linkView.isUserInteractionEnabled = false
            self.contentView.addSubview(linkView)
            linkView.frame = self.contentView.frame
        }
    }
    
    private func setupInvalidLinkPresentation() {
        DispatchQueue.main.async {
            let imageView = UIImageView(image: UIImage(named: "notAvailable"))
            self.contentView.addSubview(imageView)
            imageView.frame = self.contentView.frame
        }
    }
    
}
