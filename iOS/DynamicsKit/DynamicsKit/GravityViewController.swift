//
//  GravityViewController.swift
//  DynamicsKit
//
//  Created by Anton Davydov on 2/13/15.
//  Copyright (c) 2015 EPAM Systems. All rights reserved.
//

import UIKit

class GravityViewController: UIViewController, UICollisionBehaviorDelegate {

    var animator: UIDynamicAnimator!

    @IBOutlet var barriers: [UILabel]!
    @IBOutlet weak var dynamicView: UIImageView!

    @IBOutlet weak var angul: UISlider!
    @IBOutlet weak var elas: UISlider!
    @IBOutlet weak var fric: UISlider!
    @IBOutlet weak var den: UISlider!

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        animator = UIDynamicAnimator()
        startAnumation()
    }

    func startAnumation() {

        let item = UIDynamicItemBehavior(items: [dynamicView])
        item.elasticity = CGFloat(elas.value)
        item.friction = CGFloat(fric.value)
        item.density = CGFloat(den.value)
        item.resistance = CGFloat(angul.value)

        animator.addBehavior(item)

        let gravity = UIGravityBehavior(items: [dynamicView])
        animator.addBehavior(gravity)


        let collision = UICollisionBehavior(items: (barriers + [dynamicView]))
        collision.addBoundaryWithIdentifier("barries1", forPath: UIBezierPath(rect: self.view.frame))
        collision.translatesReferenceBoundsIntoBoundary = true
        collision.collisionDelegate = self

        animator.addBehavior(collision)
    }

    @IBAction func refresh(sender: UITapGestureRecognizer) {

        animator.removeAllBehaviors()
        dynamicView.center = sender.locationInView(self.view)
        dynamicView.transform = CGAffineTransformIdentity;

        startAnumation()
    }

    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {

    }

    func collisionBehavior(behavior: UICollisionBehavior, endedContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem) {
        
    }
}
