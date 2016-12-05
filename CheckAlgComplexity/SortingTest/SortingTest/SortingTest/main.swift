//
//  main.swift
//  SortingTest
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

public func generateVector(amountOfPoint: Int) -> [Int] {
    return (0...amountOfPoint).map{ _ in return Int(arc4random()) }
}

print("Hello, World!")
var amountOfPoint = 10000
while amountOfPoint <= 150000 {
    let mergesortTime = measure {
        let v = generateVector(amountOfPoint: amountOfPoint)
        let result = mergeSort(v)
    }
    
    let quicksortTime = measure {
        let v = generateVector(amountOfPoint: amountOfPoint)
        let result = quicksort(v)
    }
    
    print("\(amountOfPoint) \(mergesortTime) \(quicksortTime)")
    amountOfPoint += 10000
}


