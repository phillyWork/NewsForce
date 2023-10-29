//
//  Frame.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import Foundation

enum Constant {
    
    enum Frame {
        
        static let searchOptionConfirmResetButtonCornerRadius: CGFloat = 10
        
        static let sheetPresentationDetentHeightMultiply = 0.358
        
        static let newsImageViewCornerRadius: CGFloat = 8
        static let newsImageViewLeadingOffset: CGFloat = 10
        static let newsImageViewHeightMultiply = 0.8
        
        static let newsTitleLeadingOffset: CGFloat = 15
        static let newsTitleTrailingOffset: CGFloat = -15
        static let newsTitleHeightMultiply = 0.6
        
        static let newsBookMarkButtonPointSize: CGFloat = 20
        static let newsBookMarkButtonHeightMultiply = 0.2
        
        static let newsSearchOptionCloseButtonPointSize: CGFloat = 25
        
        static let newsDateTopOffset: CGFloat = 5
        
        static let newsPressBottomInset: CGFloat = 15
        static let newsPressTrailingOffset: CGFloat = -15
        
        static let skeletonCornerRadius: Float = 8
        
        static let searchBarBorderWidth: CGFloat = 1
        
        static let emptyViewImageWidthMultiply: CGFloat = 0.65
        
        static let collectionViewCellShadowRadius = 5.0
        static let collectionViewCellShadowOpacity: Float = 0.8
        static let collectionViewCellshadowOffset = CGSize(width: 0, height: 5)
        
        static let stackViewItemSpace: CGFloat = 10
        
        static let journalCollectionViewGroupInterItemSpace: CGFloat = 15
        static let journalCollectionViewInterGroupSpace: CGFloat = 15
        static let journalCollectionViewSpacingForDoublePadding: CGFloat = 20
        static let journalCollectionViewItemFractionalWidth: CGFloat = 0.5
        static let journalCollectionViewGroupFractionalWidth: CGFloat = 1.0
        static let journalCollectionViewEstimatedHeight: CGFloat = 150
        static let journalCollectionViewRepeatingItemCount: Int = 2
        
        static let newsSearchCollectionViewInterItemSpace: CGFloat = 10
        static let newsSearchCollectionViewInterGroupSpace: CGFloat = 10
        static let newsSearchCollectionViewEdgeInsets: CGFloat = 10
        static let newsSearchCollectionViewItemFractionalWidth: CGFloat = 1.0
        static let newsSearchCollectionViewItemFractionalHeight: CGFloat = 0.25
        static let newsSearchCollectionViewGroupFractionalWidth: CGFloat = 1.0
        static let newsSearchCollectionViewGroupFractionalHeight: CGFloat = 1.0
        static let newsSearchCollectionViewRepeatingItemCount: Int = 4
        
        static let journalRealmCellDateTagInset: CGFloat = 5
        static let journalRealmCellDateHeightMultiply = 0.2
        static let journalRealmCellTagHeightMultiply = 0.15
        static let journalRealmCellLabelInset: CGFloat = 10
        static let journalRealmCellTitleLabelHeightMultiply = 0.4
        static let journalRealmCellCheckImageSizeMultiply = 0.1
        static let journalRealmCellCheckImageLeadingTopOffset: CGFloat = 5
        
        //72 points per inch
        static let pdfCreatorPageWidth =  8.3 * 72.0
        static let pdfCreatorPageHeight = 11.7 * 72.0
        static let pdfCreatorPadding: CGFloat = 36
        static let pdfCreatorPaddingForContentWidth: CGFloat = 10
        static let pdfCreatorPaddingForContentHeight: CGFloat = 18
        static let pdfCreatorPaddingForContentInset: CGFloat = 10
        static let pdfCreatorPaddingForSpaceBetweenNewsTitleAndLink: CGFloat = 20
        static let pdfCreatorPaddingForSpaceBetweenLinkAndDate: CGFloat = 10
        
        static let pdfPageInfoContainerCornerRadius: CGFloat = 8
        static let pdfPageInfoContainerOffset = 15
        static let pdfCurrentPageLabelDirectionalHorizontalOffset = 10
        static let pdfCurrentPageLabelBottomOffset = -5
        static let pdfCurrentPageLabelTopOffset = 5
        
        static let memoTitleTextFieldInset = 15
        static let memoTitleTextFieldHeightMultiply = 0.12
        static let memoTitleTextFieldCornerRadius: CGFloat = 6
        static let memoTagButtonTopOffset = 10
        static let memoTagButtonLeadingOffset = 10
        static let memoTagButtonWidthMultiply = 0.23
        static let memoTagButtonHeightMultiply = 0.34
        static let memoTagButtonCornerRadius: CGFloat = 5
        static let memoTextViewTopOffset = 10

    }

}
