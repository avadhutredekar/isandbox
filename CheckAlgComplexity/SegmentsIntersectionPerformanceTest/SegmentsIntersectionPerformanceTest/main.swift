//
//  main.swift
//  SegmentsIntersectionPerformanceTest
//
//  Created by Anton Davydov on 14/12/2016.
//  Copyright © 2016 dydus. All rights reserved.
//

import Foundation
import CoreGraphics

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

public func measure(closure: ()->Void) -> Double {
    var index = 0
    var time: Double = 0
    while index < 3 {
        let start = DispatchTime.now()
        closure()
        let finish = DispatchTime.now()
        time += Double(finish.uptimeNanoseconds - start.uptimeNanoseconds)
            / 1_000_000_000
        index += 1
    }
    
    return time / 3
}


var amountOfSegments = 10
while amountOfSegments <= 200 {
    let size = CGSize(width: 10000*amountOfSegments, height: 10000*amountOfSegments)
    var count = 0
    let segmentIntersectionTime = measure {
        let v = generateSegments(amountOfSegments, size)
        count = segmentIntersection(v).count
    }
    
    print("\(amountOfSegments) \(count) \(segmentIntersectionTime)")
    amountOfSegments += 10
}
