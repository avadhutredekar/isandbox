//
//  AnimatedCircleImageView.swift
//  CustomAnimations
//
//  Created by Anton Davydov on 5/19/15.
//  Copyright (c) 2015 dydus0x14. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable public class AnimatedCircleImageView: UIView {
	private var icon: UIImageView = UIImageView()
	private var borderLayer = CAShapeLayer()
	private var imageLayer = CAShapeLayer()
	private var widthLayer: CGFloat = 10.0

	public var startAngle: Double = -90.0
	public var imageAnimationDuration: NSTimeInterval = 0.5
	public var borderAnimationDuration: NSTimeInterval = 0.5
	public var timingFunc = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

	@IBInspectable var image: UIImage {
		get {
			return icon.image!
		}
		set(value) {
			self.icon.image = value
			self.setNeedsDisplay()
		}
	}

	@IBInspectable var borderWidth: CGFloat {
		get {
			return widthLayer
		}
		set(value) {
			self.widthLayer = value
			setNeedsLayout()
		}
	}

	@IBInspectable var borderColor: UIColor {
		get {
			return UIColor(CGColor: borderLayer.strokeColor)!
		} set(value) {
			borderLayer.strokeColor = value.CGColor
			setNeedsLayout()
		}
	}

	public override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		initLayers()
		initBezierForAnimation()
		setNeedsLayout()
	}

	public required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initLayers()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		initLayers()
	}

	public override func layoutSubviews() {
		super.layoutSubviews()

		self.borderLayer.frame = self.bounds
		self.imageLayer.frame = self.bounds

		self.icon.frame = self.bounds
		self.icon.layer.frame = self.bounds
		self.icon.layer.masksToBounds = true
		self.icon.layer.cornerRadius =  min(self.frame.height / 2, self.frame.width / 2)
	}

	public func startAnimation() {
		initBezierForAnimation()

		let animateStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
		animateStrokeEnd.duration = self.borderAnimationDuration
		animateStrokeEnd.fromValue = 0.0
		animateStrokeEnd.toValue = 1.0
		animateStrokeEnd.timingFunction = timingFunc
		borderLayer.addAnimation(animateStrokeEnd, forKey: "animate stroke end")

		self.imageLayer.path = self.createBezierPath(0).CGPath
		var animationPath = CABasicAnimation(keyPath: "path")
		animationPath.fromValue = self.createBezierPath(0).CGPath
		animationPath.toValue = self.createBezierPath(self.bounds.height / 2.0).CGPath
		animationPath.delegate = self
		animationPath.repeatCount = 0
		animationPath.duration = self.imageAnimationDuration
		animationPath.removedOnCompletion = true
		animationPath.timingFunction = timingFunc
		self.imageLayer.addAnimation(animationPath, forKey: "path")

		icon.layer.opacity = 1.0
		var animationOpacity = CABasicAnimation(keyPath: "opacity")
		animationOpacity.fromValue = 0
		animationOpacity.toValue = 1
		animationOpacity.repeatCount = 0
		animationOpacity.duration = self.imageAnimationDuration
		animationOpacity.removedOnCompletion = true
		animationOpacity.timingFunction = timingFunc
		icon.layer.addAnimation(animationOpacity, forKey: "opacity")
	}

	private func initLayers() {
		self.icon.contentMode = .ScaleAspectFill
		self.icon.layer.masksToBounds = true
		self.imageLayer.masksToBounds = true
		self.imageLayer.addSublayer(icon.layer)
		//addSubview(icon)
		self.layer.addSublayer(self.imageLayer)
		self.layer.addSublayer(self.borderLayer)
	}

	private func initBezierForAnimation() {
		let ovalStartAngle = CGFloat((startAngle + 0.01) * M_PI/180)
		let ovalEndAngle = CGFloat(startAngle * M_PI/180)
		let ovalRect = self.bounds

		let ovalPath = UIBezierPath()

		ovalPath.addArcWithCenter(CGPointMake(CGRectGetMidX(ovalRect), CGRectGetMidY(ovalRect)),
			radius: CGRectGetWidth(ovalRect) / 2,
			startAngle: ovalStartAngle,
			endAngle: ovalEndAngle, clockwise: true)

		borderLayer.path = ovalPath.CGPath
		borderLayer.fillColor = UIColor.clearColor().CGColor
		borderLayer.lineWidth = widthLayer
		borderLayer.lineCap = kCALineCapRound
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