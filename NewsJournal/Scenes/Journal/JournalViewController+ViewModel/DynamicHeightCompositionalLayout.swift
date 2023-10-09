//
//  DynamicHeightCompositionalLayout.swift
//
//

import UIKit
 
struct Ratio {
    var ratio: CGFloat
}

final class DynamicHeightCompositionalLayout {
    
    var section: NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection(group: customLayoutGroup)
        section.contentInsets = .init(top: 10, leading: padding, bottom: 10, trailing: padding)
        return section
    }
    
    //MARK: - Private methods
    
    private let numberOfColumns: Int
    private let itemRatios: [Ratio]
    private let spacing: CGFloat
    private let contentWidth: CGFloat
    
    private var padding: CGFloat {
        spacing / 2
    }
    
    // Padding around cells equal to the distance between cells
    private var insets: NSDirectionalEdgeInsets {
        return .init(top: padding, leading: padding, bottom: padding, trailing: padding)
    }
    
    private lazy var frames: [CGRect] = {
        calculateFrames()
    }()
    
    // Max height for section
    private lazy var sectionHeight: CGFloat = {
        (frames
            .map(\.maxY)
            .max() ?? 0
        ) + insets.bottom
    }()
    
    private lazy var customLayoutGroup: NSCollectionLayoutGroup = {
        let layoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(sectionHeight)
        )
        return NSCollectionLayoutGroup.custom(layoutSize: layoutSize) { _ in
            self.frames.map { .init(frame: $0) }
        }
    }()
    
    init(
        columnsCount: Int,
        itemRatios: [Ratio],
        spacing: CGFloat,
        contentWidth: CGFloat
    ) {
        self.numberOfColumns = columnsCount
        self.itemRatios = itemRatios
        self.spacing = spacing
        self.contentWidth = contentWidth
    }
     
    private func calculateFrames() -> [CGRect] {
        var contentHeight: CGFloat = 0
        
        let columnWidth = (contentWidth - insets.leading - insets.trailing) / CGFloat(numberOfColumns)
        
        let xOffset = (0..<numberOfColumns).map { CGFloat($0) * columnWidth }
        
        var currentColumn = 0
        
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
        var frames = [CGRect]()
        
        for index in 0..<itemRatios.count {
            let aspectRatio = itemRatios[index]
            
            let frame = CGRect(
                x: xOffset[currentColumn],
                y: yOffset[currentColumn],
                width: columnWidth,
                height: columnWidth / aspectRatio.ratio
            )
            .insetBy(dx: padding, dy: padding)
            .offsetBy(dx: 0, dy: insets.leading)
            .setHeight(ratio: aspectRatio.ratio)
            
            frames.append(frame)
        
            let columnLowestPoint = frame.maxY
            contentHeight = max(contentHeight, columnLowestPoint)
            yOffset[currentColumn] = columnLowestPoint
            currentColumn = yOffset.indexOfMinElement ?? 0
        }
        return frames
    }
}

private extension Array where Element: Comparable {
    
    var indexOfMinElement: Int? {
        guard count > 0 else { return nil }
        var min = first
        var index = 0
        
        indices.forEach { i in
            let currentItem = self[i]
            if let minumum = min, currentItem < minumum {
                min = currentItem
                index = i
            }
        }
        
        return index
    }
}

private extension CGRect {
    func setHeight(ratio: CGFloat) -> CGRect {
        .init(x: minX, y: minY, width: width, height: width / ratio)
    }
}
