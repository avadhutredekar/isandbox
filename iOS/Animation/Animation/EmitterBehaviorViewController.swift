//
//  EmitterBehaviorViewController.swift
//  Animation
//
//  Created by Anton Davydov on 21/09/2015.
//  Copyright © 2015 Anton Davydov. All rights reserved.
//

import UIKit


// Source http://www.raywenderlich.com/77983/make-letter-word-game-uikit-swift-part-33
class EmitterBehaviorViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    private let image = UIImage(named: "apple")!
    private var data: [(image: UIImage, checked: Bool)] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func addItem(sender: AnyObject) {
        self.data += [(self.image, false)]
    }
}

extension EmitterBehaviorViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let checked = self.data[indexPath.row].checked
        self.data[indexPath.row].checked = !checked
        
        collectionView.reloadItemsAtIndexPaths([indexPath])
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EmitterCollectionCell", forIndexPath: indexPath) as! EmitterCell
        
        cell.image.image = self.data[indexPath.row].image
        cell.emitterView.alive = !self.data[indexPath.row].checked
        
        return cell
    }
}