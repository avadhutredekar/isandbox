import UIKit
import XCPlayground
import PlaygroundSupport

let rect = CGRect(x: 0, y: 0, width: 500, height: 500)
let vector = generateVector(amountOfPoint: 10, size: rect.size)
let jarvisResult = jarvis(input: vector)
let grahResult = graham(input: vector)

let view = UIView(frame: rect)
view.backgroundColor = UIColor.white

PlaygroundPage.current.liveView = view

extension Point {
    var cgpoint: CGPoint {
        return CGPoint(x: x, y: y)
    }
}

let circleLayer: (CGPoint)->CALayer = {
    let circlePath = UIBezierPath(arcCenter: $0,
                                  radius: CGFloat(5), startAngle: CGFloat(0),
                                  endAngle:CGFloat(M_PI * 2), clockwise: true)
    
    let shapeLayer = CAShapeLayer()
    shapeLayer.path = circlePath.cgPath
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = UIColor.green.cgColor
    shapeLayer.lineWidth = 3.0
    
    return shapeLayer
}

let pathLayer: ([CGPoint], CGColor)->CALayer = {
    let layer = CAShapeLayer()
    layer.lineWidth = 1.0
    layer.fillColor = UIColor.clear.cgColor
    layer.strokeColor = $1
    
    let path = UIBezierPath()
    path.lineWidth = 1.0
    
    let first = $0[0]
    path.move(to: first)
    for item in $0 {
        path.addLine(to: item)
    }
    path.addLine(to: first)
    path.close()
    layer.path = path.cgPath
    return layer
}

for item in vector {
    let point = CGPoint(x: item.x, y: item.y)
    view.layer.addSublayer(circleLayer(point))
}

view.layer.addSublayer(pathLayer(
    grahResult.map{ vector[$0].cgpoint }, UIColor.red.cgColor))

view.layer.addSublayer(pathLayer(
    jarvisResult.map{ vector[$0].cgpoint }, UIColor.blue.cgColor))

print("Hello, Convex Hull")
