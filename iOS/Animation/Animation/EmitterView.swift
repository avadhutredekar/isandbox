//
//  EmitterView.swift
//  Animation
//
//  Created by Anton Davydov on 21/09/2015.
//  Copyright © 2015 Anton Davydov. All rights reserved.
//

import UIKit

class EmitterView: UIView {
    
    private var emitterLayer: CAEmitterLayer!
    private var emitterCell: CAEmitterCell!
    var alive: Bool! {
        didSet {
            if let alive = alive where alive == true {
                emitterLayer.emitterCells = [emitterCell]
            } else {
                emitterLayer.emitterCells = []
            }
        }
    }
    
    override class func layerClass() -> AnyClass {
        return CAEmitterLayer.self
    }
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
        self.setUpEmitter()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpEmitter()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.superview == nil {
            return
        }
        
        let texture:UIImage? = UIImage(named:"particle")
        assert(texture != nil, "particle image not found")
        
        emitterCell = CAEmitterCell()
        emitterCell.contents = texture!.CGImage
        emitterCell.name = "cell"
        emitterCell.birthRate = 15 // 1000 particles per second
        emitterCell.lifetime = 0.75
        emitterCell.scale = 0.05
        emitterCell.scaleRange = 0.5
        emitterCell.scaleSpeed = -0.1
        emitterCell.emissionRange = CGFloat(M_PI*2)
    }
    
    private func setUpEmitter() {
        emitterLayer = self.layer as! CAEmitterLayer
        emitterLayer.emitterPosition = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
        var size = self.bounds.size
        size.height -= 16
        size.width -= 16
        emitterLayer.emitterSize = size
        emitterLayer.emitterMode = kCAEmitterLayerAdditive
        emitterLayer.emitterShape = kCAEmitterLayerCircle
    }
}
