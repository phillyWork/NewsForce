//
//  PDFDocumentCreator.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/01.
//

import Foundation
import PDFKit
import RealmSwift

final class PDFDocumentCreator: NSObject {
    
    //MARK: - Properties
    
    let selectedJournals: [Journal]
    
    init(_ selectedJournals: [Journal]) {
        self.selectedJournals = selectedJournals
    }
    
    //MARK: - API
    
    func createPDFDocumentData() -> Data {
        
        //setup PDFMetaData
        let pdfMetaData = [
            kCGPDFContextCreator: "NewsJournal",
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        //setup PDF Size
        let pageRect = CGRect(origin: .zero, size: CGSize(width: Constant.Frame.pdfCreatorPageWidth, height: Constant.Frame.pdfCreatorPageHeight))
        
        //PDFRenderer
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        //create PDF Data
        let data = renderer.pdfData { context in
            for journal in selectedJournals {
                //start new page for each journal
                context.beginPage()
                
                //newsTitle
                let newsTitleBottom = addNewsTitle(pageRect: pageRect, journal: journal)
                //newsLink
                let newsLinkBottom = addNewsSubValue(subType: .link, pageRect: pageRect, textTop: newsTitleBottom, journal: journal)
                //newsPubDate
                let newsPubDateBottom = addNewsSubValue(subType: .pubDate, pageRect: pageRect, textTop: newsLinkBottom, journal: journal)
                
                guard let memo = journal.memo else { continue }
                //memoTitle
                let memoTitleBottom = addMemoTitle(pageRect: pageRect, textTop: newsPubDateBottom, memo: memo)
                //memoCreatedAt
                let memoCreatedAtBottom = addMemoSubValue(subType: .createdAt, pageRect: pageRect, textTop: memoTitleBottom, memo: memo)
                //memoEditedAt
                let memoEditedAtBottom = addMemoSubValue(subType: .editedAt, pageRect: pageRect, textTop: memoCreatedAtBottom, memo: memo)
                
                if let tags = memo.tags {
                    //tag 존재 시 추가
                    let memoTagsBottom = addMemoTags(pageRect: pageRect, textTop: memoEditedAtBottom, tags: tags)
                    //memoContent
                    addMemoContent(pageRect: pageRect, textTop: memoTagsBottom + Constant.Frame.pdfCreatorPadding, context: context, memo: memo)
                } else {
                    //없으면 바로 memoContent로
                    addMemoContent(pageRect: pageRect, textTop: memoEditedAtBottom + Constant.Frame.pdfCreatorPadding, context: context, memo: memo)
                }
            }
        }
        return data
    }
    
}

//MARK: - Extension for PDF components draw

extension PDFDocumentCreator {
    
    private func addNewsTitle(pageRect: CGRect, journal: Journal) -> CGFloat {
        let titleFont = Constant.Font.pdfCreatorNewsTitle
        let titleAttributes = [NSAttributedString.Key.font: titleFont]

        let attributedTitle = NSAttributedString(string: journal.title, attributes: titleAttributes)
        let titleStringSize = attributedTitle.size()
        
        var titleStringRect: CGRect
        
        //왼쪽에서 시작: 오른쪽 벗어나는 길이 고려하기
        if titleStringSize.width >= pageRect.width {
            titleStringRect = CGRect(x: Constant.Frame.pdfCreatorPadding, y: Constant.Frame.pdfCreatorPadding, width: pageRect.width - Constant.Frame.pdfCreatorPadding * 2, height: titleStringSize.height * 2)
        } else {
            titleStringRect = CGRect(x: Constant.Frame.pdfCreatorPadding, y: Constant.Frame.pdfCreatorPadding, width: titleStringSize.width, height: titleStringSize.height)
        }
        
        attributedTitle.draw(in: titleStringRect)
        return titleStringRect.origin.y + titleStringRect.size.height
    }
    
    private func addNewsSubValue(subType: NewsSubDataType, pageRect: CGRect, textTop: CGFloat, journal: Journal) -> CGFloat {
        let valueFont = Constant.Font.pdfCreatorLinkDate
        let valueColor = Constant.Color.linkDateShadowText
        let valueAttributes = [NSAttributedString.Key.font: valueFont,
                               NSAttributedString.Key.foregroundColor: valueColor]
        
        var attributedValue: NSAttributedString
        switch subType {
        case .link:
            attributedValue = NSAttributedString(string: subType.text + journal.link, attributes: [NSAttributedString.Key.font: valueFont,
                                                                                              NSAttributedString.Key.foregroundColor: valueColor])
        case .pubDate:
            attributedValue = NSAttributedString(string: subType.text + journal.pubDate, attributes: [NSAttributedString.Key.font: valueFont,
                                                                                                   NSAttributedString.Key.foregroundColor: valueColor])
        }
        
        let valueSize = attributedValue.size()
        let valueRect = CGRect(x: Constant.Frame.pdfCreatorPadding, y: textTop, width: valueSize.width, height: valueSize.height)
        
        attributedValue.draw(in: valueRect)
        return valueRect.origin.y + valueRect.size.height
    }
    
    private func addMemoTitle(pageRect: CGRect, textTop: CGFloat, memo: MemoTable) -> CGFloat {
                
        let memoTitleFont = Constant.Font.pdfCreatorMemoTitle
        let titleAttributes = [NSAttributedString.Key.font: memoTitleFont]
        let attributedMemoTitle = NSAttributedString(string: memo.title, attributes: titleAttributes)
        
        let memoTitleStringSize = attributedMemoTitle.size()
        
        var memoTitleStringRect: CGRect
        //왼쪽에서 시작: size 크기 고려
        if memoTitleStringSize.width >= pageRect.width {
            memoTitleStringRect = CGRect(x: Constant.Frame.pdfCreatorPadding, y: textTop, width: pageRect.width - Constant.Frame.pdfCreatorPadding * 2 , height: memoTitleStringSize.height * 2)
        } else {
            memoTitleStringRect = CGRect(x: Constant.Frame.pdfCreatorPadding, y: textTop, width: memoTitleStringSize.width, height: memoTitleStringSize.height)
        }
        
        attributedMemoTitle.draw(in: memoTitleStringRect)
        return memoTitleStringRect.origin.y + memoTitleStringRect.size.height
    }
    
    private func addMemoSubValue(subType: JournalSubDataType, pageRect: CGRect, textTop: CGFloat, memo: MemoTable) -> CGFloat {
        
        let valueFont = Constant.Font.pdfCreatorLinkDate
        let valueColor = Constant.Color.linkDateShadowText
        
        let valueAttributes = [NSAttributedString.Key.font: valueFont,
                              NSAttributedString.Key.foregroundColor: valueColor]
        
        var attributedValue: NSAttributedString
        
        switch subType {
        case .createdAt:
            attributedValue = NSAttributedString(string: subType.text + "\(memo.createdAt)", attributes: valueAttributes)
        case .editedAt:
            attributedValue = NSAttributedString(string: subType.text + "\(memo.editedAt)", attributes: valueAttributes)
        }
        
        let valueSize = attributedValue.size()
        let valueRect = CGRect(x: Constant.Frame.pdfCreatorPadding, y: textTop, width: valueSize.width, height: valueSize.height)
        
        attributedValue.draw(in: valueRect)
        return valueRect.origin.y + valueRect.size.height
    }
    
    private func addMemoTags(pageRect: CGRect, textTop: CGFloat, tags: TagTable) -> CGFloat {
        
        let tagFont = Constant.Font.pdfCreatorTag
        
        let tagAttributes = [NSAttributedString.Key.font: tagFont]
        
        var tagString = PDFCreatorSetValues.basicTag
        
        if let first = tags.firstTag {
            tagString += " #\(first.rawValue)"
        }
        if let second = tags.secondTag {
            tagString += " #\(second.rawValue)"
        }
        if let third = tags.thirdTag {
            tagString += " #\(third.rawValue)"
        }
        
        let attributedTag = NSAttributedString(string: tagString, attributes: tagAttributes)
        let tagSize = attributedTag.size()
        let tagRect = CGRect(x: Constant.Frame.pdfCreatorPadding, y: textTop, width: tagSize.width, height: tagSize.height)
        
        attributedTag.draw(in: tagRect)
        return tagRect.origin.y + tagRect.size.height
    }
    
    private func addMemoContent(pageRect: CGRect, textTop: CGFloat, context: UIGraphicsPDFRendererContext, memo: MemoTable) {
                
        let textFont = Constant.Font.pdfCreatorContent
        
        //paragraphStyle: how text should flow and wrap
        let paragraphStyle = NSMutableParagraphStyle()
        //natural alignment: localization of app
        paragraphStyle.alignment = .natural
        //lines wrap at word breaks
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let textAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: textFont
        ]
        
        let attributedText = NSAttributedString(string: memo.content, attributes: textAttributes)
        
        //consider multiple pages for one document, especially for long memo
        let layoutManager = NSLayoutManager(), textStorage = NSTextStorage()
        textStorage.append(attributedText)
        textStorage.addLayoutManager(layoutManager)

        var textContainerSize = CGSize(width: pageRect.width - Constant.Frame.pdfCreatorPaddingForContentWidth * 2, height: pageRect.height - Constant.Frame.pdfCreatorPaddingForContentHeight * 2)
        var textContainer: NSTextContainer
        var textViews = [UITextView]()
        
        var startPoint = textTop
        let startContainerSize = CGSize(width: pageRect.width - Constant.Frame.pdfCreatorPaddingForContentWidth * 2, height: pageRect.height - textTop - Constant.Frame.pdfCreatorPaddingForContentHeight * 2)
        
        repeat {
            if startPoint > 0 {
                textContainerSize = startContainerSize
                startPoint = 0
            } else {
                textContainerSize = CGSize(width: pageRect.width - Constant.Frame.pdfCreatorPaddingForContentWidth * 2, height: pageRect.height - Constant.Frame.pdfCreatorPaddingForContentHeight * 2)
            }
                
            textContainer = NSTextContainer(size: textContainerSize)
            layoutManager.addTextContainer(textContainer)
            let textView = UITextView(frame: CGRect(x: Constant.Frame.pdfCreatorPaddingForContentWidth, y: Constant.Frame.pdfCreatorPaddingForContentHeight, width: textContainerSize.width, height: textContainerSize.height), textContainer: textContainer)
            textViews.append(textView)
        } while layoutManager.textContainer(forGlyphAt: layoutManager.numberOfGlyphs - 1, effectiveRange: nil) == nil

        var remainingPoint = textTop
        
        //draw each textView
        for textView in textViews {
            
            if startPoint == 0 {
                if remainingPoint + startContainerSize.height > pageRect.height - Constant.Frame.pdfCreatorPaddingForContentHeight {
                    remainingPoint = Constant.Frame.pdfCreatorPaddingForContentHeight
                    startPoint = 1
                    context.beginPage()
                } else {
                    startPoint = 1
                    context.cgContext.translateBy(x: Constant.Frame.pdfCreatorPaddingForContentWidth, y: remainingPoint)
                    textView.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
                    textView.layer.render(in: context.cgContext)
                    remainingPoint += startContainerSize.height
                }
            } else {
                context.beginPage()
                remainingPoint = Constant.Frame.pdfCreatorPaddingForContentHeight
            }
                        
            context.cgContext.translateBy(x: Constant.Frame.pdfCreatorPaddingForContentWidth, y: remainingPoint)
          
            textView.textContainerInset = .init(top: Constant.Frame.pdfCreatorPaddingForContentInset, left: Constant.Frame.pdfCreatorPaddingForContentInset, bottom: Constant.Frame.pdfCreatorPaddingForContentInset, right: Constant.Frame.pdfCreatorPaddingForContentInset)
            textView.backgroundColor = .orange
            textView.layer.render(in: context.cgContext)
            
            remainingPoint += textContainerSize.height
        }
        
    }
    
}
