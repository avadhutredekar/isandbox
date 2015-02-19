//
//  Layout.swift
//  DynamicsKit
//
//  Created by Anton Davydov on 2/19/15.
//  Copyright (c) 2015 EPAM Systems. All rights reserved.
//

import UIKit
import Foundation

class Layout: UICollectionViewLayout {

    var animator: UIDynamicAnimator!

    override init() {
        super.init()
        animator = UIDynamicAnimator(collectionViewLayout: self)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareLayout() {
        super.prepareLayout()
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        return self.animator.itemsInRect(rect)
    }

    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        return self.animator.layoutAttributesForCellAtIndexPath(indexPath)
    }

    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        let scroll: UIScrollView = self.collectionView!
        let delta: CGFloat = newBounds.origin.y - scroll.bounds.origin.y

        let touchLocation = collectionView!.panGestureRecognizer.locationInView(collectionView)

        var array: NSArray = self.animator.behaviors
        array.enumerateObjectsUsingBlock({ spring, idx, stop in
            let yDistanceFromTouch = fabsf(Float(touchLocation.y - spring.anchorPoint.y))
            let xDistanceFromTouch = fabsf(Float(touchLocation.x - spring.anchorPoint.x))
            let scrollResistance: CGFloat = CGFloat(yDistanceFromTouch + xDistanceFromTouch) / CGFloat(1500.0)

            let item = spring.items![0] as UICollectionViewLayoutAttributes
            var center: CGPoint = item.center;

            let d: CGFloat = delta < 0 ?
                max(delta, delta*scrollResistance) :
                min(delta, delta*scrollResistance)

            center.y += d
            item.center = center;
            self.animator.updateItemUsingCurrentState(item)
        })


        return false
    }
}
