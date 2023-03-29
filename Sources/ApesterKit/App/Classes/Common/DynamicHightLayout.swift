//
//  DynamicHightLayout.swift
//  ApesterDemo
//
//  Created by Arkadi Yoskovitz on 12/8/22.
//
import Foundation
import UIKit
///
///
///
final class DynamicHightLayout : UICollectionViewFlowLayout {
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        guard let collectionView = collectionView else {
            fatalError()
        }
        
        let originalAttributes = super.layoutAttributesForItem(at: indexPath)
        
        guard let attributes = originalAttributes?.copy() as? UICollectionViewLayoutAttributes else {
            return nil
        }
        
        attributes.frame.origin.x   = sectionInset.left
        attributes.frame.size.width = collectionView.safeAreaLayoutGuide.layoutFrame.width - sectionInset.left - sectionInset.right
        return attributes
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let originalAttributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        var attributes = [UICollectionViewLayoutAttributes]()
        for attribute in originalAttributes {
            
            if attribute.representedElementCategory == .cell
            {
                if let newFrame = layoutAttributesForItem(at: attribute.indexPath)?.frame
                {
                    attribute.frame = newFrame
                }
            }
            attributes.append(attribute)
        }
        return attributes
    }
}

