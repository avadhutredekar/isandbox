//
//  CollectionController.swift
//  DynamicsKit
//
//  Created by Anton Davydov on 2/19/15.
//  Copyright (c) 2015 EPAM Systems. All rights reserved.
//

import UIKit

class CollectionController: UICollectionViewController {
    override func viewDidLoad() {
        
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1000
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("IDCell", forIndexPath: indexPath) as UICollectionViewCell
        cell.backgroundColor = UIColor.yellowColor()
        return cell
    }
}
