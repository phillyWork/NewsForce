//
//  JournalRealmCell.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/02.
//

import UIKit
import SnapKit

final class JournalRealmCell: BaseCollectionViewCell {
    
    //MARK: - Properties
        
    let titleLabel = UILabel()
    let editedDateLabel = UILabel()
    let tagLabel = UILabel()
    let memoLabel = UILabel()
    let checkImage = UIImageView(image: UIImage(systemName: Constant.ImageString.checkImageString))
        
    //MARK: - Setup
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        editedDateLabel.text = nil
        tagLabel.text = nil
        memoLabel.text = nil
    }
    
    override func configCell() {
        super.configCell()
        
        configureView()
        setConstraints()
    }
    
    private func configureView() {
        contentView.backgroundColor = Constant.Color.journalBackgroundRed
        contentView.layer.cornerRadius = 15
        contentView.clipsToBounds = true
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(editedDateLabel)
        contentView.addSubview(tagLabel)
        contentView.addSubview(memoLabel)
        contentView.addSubview(checkImage)

        titleLabel.font = Constant.Font.journalRealmCellTitle
        titleLabel.textColor = Constant.Color.whiteBackground
        titleLabel.numberOfLines = JournalRealmSetupValues.titleNumberOfLines
        titleLabel.numberOfLines = 3
        
        editedDateLabel.font = Constant.Font.journalRealmCellEditedAt
        editedDateLabel.textColor = Constant.Color.whiteBackground
        editedDateLabel.numberOfLines = 2

        tagLabel.font = Constant.Font.journalRealmCellTag
        tagLabel.textColor = Constant.Color.whiteBackground
        
        memoLabel.font = Constant.Font.journalRealmCellMemo
        memoLabel.textColor = Constant.Color.whiteBackground
        memoLabel.numberOfLines = JournalRealmSetupValues.memoNumberOfLines
        
        checkImage.tintColor = Constant.Color.mainRed
        checkImage.isHidden = true
    }
    
    private func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.directionalHorizontalEdges.equalTo(contentView).inset(Constant.Frame.journalRealmCellLabelInset)
            make.height.equalTo(titleLabel.snp.width).multipliedBy(Constant.Frame.journalRealmCellTitleLabelHeightMultiply)
        }
        
        editedDateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Constant.Frame.journalRealmCellDateTagInset)
            make.directionalHorizontalEdges.equalTo(contentView).inset(Constant.Frame.journalRealmCellLabelInset)
            make.height.equalTo(editedDateLabel.snp.width).multipliedBy(Constant.Frame.journalRealmCellDateHeightMultiply)
        }
        
        tagLabel.snp.makeConstraints { make in
            make.top.equalTo(editedDateLabel.snp.bottom).inset(Constant.Frame.journalRealmCellDateTagInset)
            make.directionalHorizontalEdges.equalTo(contentView).inset(Constant.Frame.journalRealmCellLabelInset)
            make.height.equalTo(tagLabel.snp.width).multipliedBy(Constant.Frame.journalRealmCellTagHeightMultiply)
        }
        
        memoLabel.snp.makeConstraints { make in
            make.top.equalTo(tagLabel.snp.bottom).offset(Constant.Frame.journalRealmCellLabelInset)
            make.bottom.directionalHorizontalEdges.equalTo(contentView).inset(Constant.Frame.journalRealmCellLabelInset)
        }
        
        checkImage.snp.makeConstraints { make in
            make.top.trailing.equalTo(contentView).inset(Constant.Frame.journalRealmCellLabelInset)
            make.width.equalTo(contentView).multipliedBy(Constant.Frame.journalRealmCellCheckImageSizeMultiply)
            make.height.equalTo(checkImage.snp.width)
        }
    }

}
