//
//  main.swift
//  AlgTest
//
//  Created by Anton Davydov on 05/12/2016.
//  Copyright © 2016 dydus. All rights reserved.
//

import Foundation

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

print("Hello, World!")
var amountOfPoint = 10000
while amountOfPoint <= 150000 {
    let grahamTime = measure {
        let v = generateVector(amountOfPoint: amountOfPoint, size: CGSize(width: 10000, height: 10000))
        let result = graham(input: v)
    }
    
    let jarvisTime = measure {
        let v = generateVector(amountOfPoint: amountOfPoint, size: CGSize(width: 10000, height: 10000))
        let result = jarvis(input: v)
    }
    
    print("\(amountOfPoint) \(grahamTime) \(jarvisTime)")
    amountOfPoint += 10000
}
