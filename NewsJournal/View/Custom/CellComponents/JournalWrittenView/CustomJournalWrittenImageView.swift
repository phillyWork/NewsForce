//
//  CustomJournalWrittenImageView.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/15.
//

import UIKit

final class CustomJournalWrittenImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configImageView() {
        image = UIImage(systemName: Constant.ImageString.hasJournalWithImageString)
        tintColor = Constant.Color.mainRed
        isHidden = true
    }
    
    func showImageView() {
        isHidden = false
    }
    
    func hideImageView() {
        isHidden = true
    }
    
}

