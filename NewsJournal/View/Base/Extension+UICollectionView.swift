//
//  Extension+UICollectionView.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/07.
//

import UIKit

extension UICollectionView {
    
    func setupBackgroundNoAPIResultEmptyView() {
        let emptyView: UIView = {
            let view = UIView()
            view.backgroundColor = Constant.Color.whiteBackground
            return view
        }()
        
        let noResultImage: UIImageView = {
            let iv = UIImageView()
            iv.image = UIImage(named: Constant.ImageString.noResultsInKor)
            iv.contentMode = .scaleAspectFill
            return iv
        }()
        
        emptyView.addSubview(noResultImage)
        
        self.backgroundView = emptyView
        
        noResultImage.snp.makeConstraints { make in
            make.center.equalTo(emptyView.snp.center)
            make.width.equalTo(emptyView.snp.width).multipliedBy(Constant.Frame.emptyViewImageWidthMultiply)
            make.height.equalTo(noResultImage.snp.width)
        }
    }
    
    func setupBackgroundNoJournalSavedEmptyView() {
        let emptyView: UIView = {
            let view = UIView()
            view.backgroundColor = Constant.Color.whiteBackground
            return view
        }()
        
        let noResultImage: UIImageView = {
            let iv = UIImageView()
            iv.image = UIImage(named: Constant.ImageString.noJournalsSavedKor)
            iv.contentMode = .scaleAspectFill
            return iv
        }()
        
        emptyView.addSubview(noResultImage)
        
        self.backgroundView = emptyView
        
        noResultImage.snp.makeConstraints { make in
            make.center.equalTo(emptyView.snp.center)
            make.width.equalTo(emptyView.snp.width).multipliedBy(Constant.Frame.emptyViewImageWidthMultiply)
            make.height.equalTo(noResultImage.snp.width)
        }
    }
    
    func setupInitialBackgroundForSearch() {
        let emptyView: UIView = {
            let view = UIView()
            view.backgroundColor = Constant.Color.whiteBackground
            return view
        }()
        
        let searchImage: UIImageView = {
            let iv = UIImageView()
            iv.image = UIImage(named: Constant.ImageString.searchForNewsArticleKorean.randomElement()!)
            iv.contentMode = .scaleAspectFill
            return iv
        }()
        
        emptyView.addSubview(searchImage)
        
        self.backgroundView = emptyView
        
        searchImage.snp.makeConstraints { make in
            make.center.equalTo(emptyView.snp.center)
            make.width.equalTo(emptyView.snp.width).multipliedBy(Constant.Frame.emptyViewImageWidthMultiply)
            make.height.equalTo(searchImage.snp.width)
        }
        
    }
    
    func restoreBackgroundFromEmptyView() {
        self.backgroundView = nil
    }
    
}
