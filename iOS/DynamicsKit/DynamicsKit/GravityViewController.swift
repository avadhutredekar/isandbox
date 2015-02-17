//
//  GravityViewController.swift
//  DynamicsKit
//
//  Created by Anton Davydov on 2/13/15.
//  Copyright (c) 2015 EPAM Systems. All rights reserved.
//

import UIKit

class GravityViewController: UIViewController {

    var animator: UIDynamicAnimator!

    @IBOutlet var barriers: [UILabel]!
    @IBOutlet weak var dynamicView: UILabel!

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

        //let collision = UICollisionBehavior(items: (barriers + [dynamicView]))
        let collision = UICollisionBehavior(items: [dynamicView])
        collision.addBoundaryWithIdentifier("barries1", forPath: UIBezierPath(rect: barriers[0].frame))
        collision.addBoundaryWithIdentifier("barries2", forPath: UIBezierPath(rect: barriers[1].frame))



        animator.addBehavior(collision)
    }

    @IBAction func refresh(sender: UITapGestureRecognizer) {
        animator.removeAllBehaviors()
        dynamicView.center = sender.locationInView(self.view)
        dynamicView.transform = CGAffineTransformIdentity;

        startAnumation()
    }
}
