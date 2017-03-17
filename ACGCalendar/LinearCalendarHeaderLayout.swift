//
//  LinearCalendarHeaderLayout.swift
//  AppusCalendar
//
//  Created by Anton Poltoratskyi on 3/15/17.
//  Copyright © 2017 Appus. All rights reserved.
//

import UIKit

open class LinearCalendarHeaderLayout: UICollectionViewFlowLayout {
    
    private var lastCollectionViewSize = CGSize.zero
    
    public var scalingOffset: CGFloat = 200.0
    public var minScale: CGFloat = 0.8
    public var minAlpha: CGFloat = 0.7
    
    public var shouldScaleItems = true
    
    override open func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        
        guard let collectionView = collectionView else {
            return
        }
        let newCollectionSize = collectionView.bounds.size
        if newCollectionSize != lastCollectionViewSize {
            lastCollectionViewSize = newCollectionSize
        }
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let collectionView = collectionView, self.shouldScaleItems else {
            return super.layoutAttributesForElements(in: rect)
        }
        guard let superAttributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        let contentOffset = collectionView.contentOffset
        let size = collectionView.bounds.size
        
        let visibleRect = CGRect(origin: contentOffset, size: size)
        
        let visibleCenterCoordinate: CGFloat
        let comparingSize: CGFloat
        
        switch scrollDirection {
        case .horizontal:
            visibleCenterCoordinate = visibleRect.midX
            comparingSize = size.width
        case .vertical:
            visibleCenterCoordinate = visibleRect.midY
            comparingSize = size.height
        }
        
        var resultAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in superAttributes {
            
            let newAttributes = attributes.copy() as! UICollectionViewLayoutAttributes
            resultAttributes.append(newAttributes)
            
            let distanceFromCenter = visibleCenterCoordinate - (scrollDirection == .horizontal ? newAttributes.center.x : newAttributes.center.y)
            let absoluteDistanceFromCenter = min(abs(distanceFromCenter), scalingOffset)
            
            let alpha = max(minAlpha, 1 - absoluteDistanceFromCenter / comparingSize / 1.5)
            let scale = max(minScale, 1 - absoluteDistanceFromCenter / comparingSize / 1.5)
            
            newAttributes.alpha = alpha
            newAttributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
        }
        return resultAttributes
    }
    
}
