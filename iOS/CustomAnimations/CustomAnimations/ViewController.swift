//
//  ViewController.swift
//  CustomAnimations
//
//  Created by Anton Davydov on 5/19/15.
//  Copyright (c) 2015 dydus0x14. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	@IBOutlet weak var circleView: AnimatedCircleImageView!

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		circleView.startAnimation()
	}
	@IBAction func animateAction(sender: AnyObject) {
		circleView.startAnimation()
	}
}

