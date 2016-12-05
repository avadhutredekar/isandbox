//
//  main.swift
//  AlgTest
//
//  Created by Anton Davydov on 04/12/2016.
//  Copyright © 2016 dydus. All rights reserved.
//

import Foundation
import CoreGraphics

public let eps: Double = 1e-8
public struct Point: Equatable {
    public var x: Double
    public var y: Double
    
    public var i: Int = 0
}

public func == (left: Point, right: Point) -> Bool {
    return (left.x < right.x) || (left.x == right.x && left.y < right.y)
}

func cw(a: Point, b: Point, c: Point) -> Bool {
    return a.x*(b.y-c.y)+b.x*(c.y-a.y)+c.x*(a.y-b.y) < 0
}

func ccw (a: Point, b: Point, c: Point) -> Bool {
    return a.x*(b.y-c.y)+b.x*(c.y-a.y)+c.x*(a.y-b.y) > 0
}

func dist(a: Point, b: Point) -> Double {
    let l = (a.x - b.x) * (a.x - b.x)
    let r = (a.y - b.y) * (a.y - b.y)
    return sqrt(l + r)
}

func area_triangle(a: Point, b: Point, c: Point) -> Double {
    if a.i == b.i || b.i == c.i || a.i == c.i {
        return 0
    }
    let l = a.x * b.y + b.x * c.y + c.x * a.y
    let r = a.y * b.x - b.y * c.x - c.y * a.x
    return 0.5 * (l - r)
}

func area_triangle_unchecked(a: Point, b: Point, c: Point) -> Double {
    let l = a.x * b.y + b.x * c.y + c.x * a.y
    let r = a.y * b.x - b.y * c.x - c.y * a.x
    return 0.5 * (l - r)
}

func point_in_box(t: Point, p1: Point, p2: Point) -> Bool {
    return
        (abs(t.x - min(p1.x, p2.x)) <= eps || min(p1.x, p2.x) <= t.x) &&
        (abs(max(p1.x, p2.x) - t.x) <= eps || max(p1.x, p2.x) >= t.x) &&
        (abs(t.y - min(p1.y, p2.y)) <= eps || min(p1.y, p2.y) <= t.y) &&
        (abs(max(p1.y, p2.y) - t.y) <= eps || max(p1.y, p2.y) >= t.y)
}

var first: Point!
infix operator -<-
func -<- (a: Point, b: Point) -> Bool {
    if a.i == first.i { return true }
    if b.i == first.i { return false }
    if ccw(a: first, b: a, c: b) { return true }
    if ccw(a: first, b: b, c: a) { return false }
    return dist(a: first, b: a) > dist(a: first, b: b)
}

public func graham(input: [Point]) -> [Int] {
    var result = [Int]()
    var array = input
    let n = input.count
    
    for (index, _) in array.enumerated() {
        array[index].i = index
    }
    
    first = array[0]
    var i = 1
    while i < n {
        if first.x > array[i].x || (first.x == array[i].x && first.y > array[i].y) {
            first = array[i]
        }
        i += 1
    }
    array.sort(by: -<-)
    result.append(0)
    
    var index = 1
    var top = 1
    while (index < n) && (abs(area_triangle(a: array[0], b: array[1], c: array[index])) <= eps) {
        index += 1
    }
    result.append(1)
    
    while index < n {
        if !ccw(a: array[result[top - 1]], b: array[result[top]], c: array[index]) {
            top -= 1
            let _ = result.popLast()
        } else {
            top += 1
            result.append(index)
            index += 1
        }
    }
    for (index, item) in result.enumerated() {
        result[index] = array[item].i
    }
    
    return result
}

func orientTriangl2(p1: Point, p2: Point, p3: Point) -> Double {
    return p1.x * (p2.y - p3.y) + p2.x * (p3.y - p1.y) + p3.x * (p1.y - p2.y)
}

func isInside(p1: Point, p: Point, p2: Point) -> Bool {
    return p1.x <= p.x && p.x <= p2.x && p1.y <= p.y && p.y <= p2.y
}

public func jarvis(input: [Point]) -> [Int] {
    var result = [Int]()
    var base = 0;
    let n = input.count
    var index = 1
    while index < n {
        if input[index].y < input[base].y {
            base = index
        } else if input[index].y == input[base].y && input[index].x < input[base].x {
            base = index
        }
        index += 1
    }
    result.append(base)
    
    let first = base
    var cur = base;
    repeat {
        var next = (cur + 1) % n
        var index = 0
        while index < n {
            let sign = orientTriangl2(p1: input[cur], p2: input[next], p3: input[index])
            if sign < 0 {
                next = index
            } else if sign == 0 && isInside(p1: input[cur], p: input[next], p2: input[index]) {
                next = index
            }
            index += 1
        }
        cur = next
        result.append(next)
    } while (cur != first)

    return result
}

public func generateVector(amountOfPoint: Int, size: CGSize) -> [Point] {
    return (1...amountOfPoint).map{ _ in Point(x:
        Double(arc4random()).truncatingRemainder(dividingBy: Double(size.width)), y:
        Double(arc4random()).truncatingRemainder(dividingBy: Double(size.height)), i: 0) }
}
