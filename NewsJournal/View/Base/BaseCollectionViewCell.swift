//
//  BaseCollectionViewCell.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/02.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCell() {
        //shadow for each cell
        layer.shadowColor = Constant.Color.cellShadow.cgColor
        layer.shadowOffset = Constant.Frame.collectionViewCellshadowOffset
        layer.shadowRadius = Constant.Frame.collectionViewCellShadowRadius
        layer.shadowOpacity = Constant.Frame.collectionViewCellShadowOpacity
        layer.masksToBounds = false
    }
    
}
