import UIKit
import XCPlayground
import PlaygroundSupport

let rect = CGRect(x: 0, y: 0, width: 500, height: 500)
let input: [Segment] = generateSegments(10, rect.size)
let result: [Point] = segmentIntersection(input)

let view = UIView(frame: rect)
view.backgroundColor = UIColor.white

PlaygroundPage.current.liveView = view

extension Point {
    var cgpoint: CGPoint {
        return CGPoint(x: x, y: y)
    }
}

func generateSegments(_ amount: Int, _ size: CGSize) -> [Segment] {
    return [Int](1...amount).map{ _ in
        var left = Point(x: Double(arc4random()).truncatingRemainder(dividingBy: Double(size.width)),
                        y: Double(arc4random()).truncatingRemainder(dividingBy: Double(size.height)))
        var right = Point(x: Double(arc4random()).truncatingRemainder(dividingBy: Double(size.width)),
                        y: Double(arc4random()).truncatingRemainder(dividingBy: Double(size.height)))
        if right < left { swap(&left, &right) }
        return Segment(l: left, r: right)
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
    shapeLayer.lineWidth = 2.0
    
    return shapeLayer
}

let lineLayer: (CGPoint, CGPoint, CGColor)->CALayer = {
    let layer = CAShapeLayer()
    layer.lineWidth = 1.0
    layer.fillColor = UIColor.clear.cgColor
    layer.strokeColor = $2
    
    let path = UIBezierPath()
    path.lineWidth = 1.0
    path.move(to: $0)
    path.addLine(to: $1)
    path.close()
    layer.path = path.cgPath
    return layer
}

for item in input {
    view.layer.addSublayer(lineLayer(item.l.cgpoint,item.r.cgpoint,UIColor.red.cgColor))
}

for item in result {
    view.layer.addSublayer(circleLayer(item.cgpoint))
}

print("Hello, Convex Hull")
