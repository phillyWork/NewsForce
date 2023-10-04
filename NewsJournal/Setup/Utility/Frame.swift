//
//  Frame.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import Foundation

enum Constant {
    
    enum Frame {
        
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
        
        static let newsSearchCollectionViewInterGroupSpace: CGFloat = 10
        static let newsSearchCollectionViewEdgeInsets: CGFloat = 10
        static let newsSearchCollectionViewItemFractionalWidth: CGFloat = 1.0
        static let newsSearchCollectionViewItemFractionalHeight: CGFloat = 1.0
        static let newsSearchCollectionViewGroupFractionalWidth: CGFloat = 1.0
        static let newsSearchCollectionViewGroupFractionalHeight: CGFloat = 0.5
        static let newsSearchCollectionViewRepeatingItemCount: Int = 1
        
        static let journalRealmCellLabelInset: CGFloat = 10
        static let journalRealmCellTitleLabelHeightMultiply = 0.3
        static let journalRealmCellCheckImageSizeMultiply = 0.1
        
        //72 points per inch
        static let pdfCreatorPageWidth =  8.3 * 72.0
        static let pdfCreatorPageHeight = 11.7 * 72.0
        static let pdfCreatorPadding: CGFloat = 36
        static let pdfCreatorPaddingForContentWidth: CGFloat = 10
        static let pdfCreatorPaddingForContentHeight: CGFloat = 18
        static let pdfCreatorPaddingForContentInset: CGFloat = 10
        
        static let pdfPageInfoContainerCornerRadius: CGFloat = 8
        static let pdfPageInfoContainerOffset = 15
        static let pdfCurrentPageLabelDirectionalHorizontalOffset = 10
        static let pdfCurrentPageLabelBottomOffset = -5
        static let pdfCurrentPageLabelTopOffset = 5
        
    }

}
