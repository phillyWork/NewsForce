//
//  BaseCollectionViewCell.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/02.
//

import UIKit

import SnapKit

class BaseCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configCell()
        setupCellComponentsConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCell() {
        
        contentView.backgroundColor = Constant.Color.whiteBackground
        contentView.layer.cornerRadius = 10
        
        //shadow for each cell
        layer.shadowColor = Constant.Color.cellShadow.cgColor
        layer.shadowOffset = Constant.Frame.collectionViewCellshadowOffset
        layer.shadowRadius = Constant.Frame.collectionViewCellShadowRadius
        layer.shadowOpacity = Constant.Frame.collectionViewCellShadowOpacity
        layer.masksToBounds = false
    }
    
    func setupCellComponentsConstraints() {
        
    }
    
}
