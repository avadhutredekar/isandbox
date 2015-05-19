//
//  PeakVoiceView.swift
//  PeakVoiceView
//
//  Created by Anton on 5/19/15.
//  Copyright (c) 2015 EPAM Systems. All rights reserved.
//

import Foundation
import UIKit

let kAnimationTag = "kLayerAnimationTag"

@IBDesignable public class PeakVoiceView: UIView {
	private var containLayer = CAShapeLayer()
	private var circleLayer = CAShapeLayer()
	private var inner: CGFloat = 0.5
	private var mainColor = UIColor.darkGrayColor().CGColor
	private var deltaPeak: CGFloat = 0
	private var previousPeak: CGFloat = 0
	private var animateSpeed: Double = 0.5

	public var peak: CGFloat = 0 {
		didSet {
			animateLayers()
			self.setNeedsLayout()
		}
	}

	required public init(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
		initLayers()
	}

	override public init(frame: CGRect) {
		super.init(frame: frame)
		initLayers()
	}

	public var innerRadius: CGFloat {
		get {
			return max(self.inner, self.peak) * self.bounds.height / 2.0
		}
	}

	@IBInspectable var minRatio: CGFloat {
		get {
			return inner
		}
		set(value) {
			self.inner = value
		}
	}

	@IBInspectable var rippleColor: UIColor {
		get {
			return UIColor(CGColor: mainColor)!
		}
		set(value) {
			self.mainColor = value.CGColor
			self.circleLayer.fillColor = self.mainColor
			if let layers = self.containLayer.sublayers as? [CAShapeLayer] {
				for layer in layers {
					layer.fillColor = self.mainColor
				}
			}

		}
	}

	@IBInspectable var speed: Double {
		get {
			return animateSpeed
		}
		set(value) {
			self.animateSpeed = value
		}
	}

	public override func prepareForInterfaceBuilder() {
		initLayers()
	}

	public override func layoutSubviews() {
		super.layoutSubviews()
		self.circleLayer.path = createBezierPath(self.innerRadius).CGPath
	}


	public override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
		if let tag = anim.valueForKey(kAnimationTag) as? CALayer {
			tag.removeFromSuperlayer()
		}
	}

	private func initLayers() {
		self.circleLayer.frame = self.bounds
		self.circleLayer.fillColor = self.mainColor
		self.circleLayer.path = createBezierPath(max(self.inner, self.peak) * self.bounds.height / 2.0).CGPath

		self.containLayer.frame = self.bounds
		self.containLayer.fillColor = UIColor.clearColor().CGColor
		self.containLayer.path = createBezierPath(self.bounds.height/2.0).CGPath
		self.layer.addSublayer(self.containLayer)
		self.layer.addSublayer(self.circleLayer)

		self.layer.cornerRadius = self.bounds.height / 2.0
		self.layer.backgroundColor = UIColor.clearColor().CGColor
	}


	private func animateLayers() {
		if deltaPeak > 0 && peak <= self.previousPeak {
			var newLayer = CAShapeLayer()
			newLayer.frame = self.bounds
			newLayer.fillColor = self.mainColor
			newLayer.path = createBezierPath(self.innerRadius).CGPath
			newLayer.opacity = 1
			self.containLayer.addSublayer(newLayer)

			var animation = CABasicAnimation(keyPath: "path")
			animation.fromValue = newLayer.path
			animation.toValue = self.createBezierPath(self.bounds.height / 2.0).CGPath
			animation.delegate = self
			animation.repeatCount = 0
			animation.duration = self.animateSpeed
			animation.removedOnCompletion = true
			animation.setValue(newLayer, forKey: kAnimationTag)
			newLayer.addAnimation(animation, forKey: "path")

			animation = CABasicAnimation(keyPath: "opacity")
			animation.fromValue = 1
			animation.toValue = 0
			animation.repeatCount = 0
			animation.duration = self.animateSpeed
			animation.removedOnCompletion = true
			newLayer.addAnimation(animation, forKey: "opacity")
		}

		self.deltaPeak = peak - self.previousPeak
		self.previousPeak = peak
	}

	private func createBezierPath(radius: CGFloat) -> UIBezierPath {
		return UIBezierPath(roundedRect: CGRect(
			x: (self.bounds.width/2 - radius),
			y: (self.bounds.height/2 - radius),
			width: 2*radius,
			height: 2*radius),
			cornerRadius: radius)
	}
}