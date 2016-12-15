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
    var base = 0
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

public struct Line {
    var a: Double
    var b: Double
    var c: Double
    
    public init(_ f: Point, _ s: Point) {
        a = s.y - f.y
        b = f.x - s.x
        c = -(a*f.x + b*f.y)
    }
    
    func dist(_ p: Point) -> Double {
        return fabs(a*p.x + b*p.y + c)/sqrt(a*a + b*b)
    }
    func isLeft(_ p: Point) -> Bool {
        return a*p.x + b*p.y + c < 0
    }
    
    func isRight(_ p: Point) -> Bool {
        return a*p.x + b*p.y + c > 0
    }
}

func GetPointsLeftByLine(_ vertex: [Point], _ setPoints: [Int], _ line: Line) -> [Int] {
    return setPoints.filter{ line.isLeft(vertex[$0]) }
}

func quickHull(_ vertex: [Point], _ leftPos: Int, _ rightPos: Int, _ setPoints: [Int]) -> [Int] {
    guard setPoints.count != 0 else {
        return [rightPos]
    }
    let lr = Line(vertex[leftPos],vertex[rightPos])
    // Находим точку, наиболее удаленную от прямой LR
    
    var topPos = setPoints[0]
    var topLine = Line(vertex[leftPos],vertex[topPos])
    var maxDist = lr.dist(vertex[topPos])
    
    var i = 1
    while i < setPoints.count {
        if setPoints[i] != leftPos && setPoints[i] != rightPos {
            let curDist = lr.dist(vertex[setPoints[i]])
            // равноудаленные точки
            if fabs(maxDist - curDist) <= eps {
                // но угол у новой точки больше
                if topLine.isLeft(vertex[setPoints[i]]) {
                    topPos = setPoints[i]
                    topLine = Line(vertex[leftPos],vertex[topPos])
                }
            }
            if (fabs(maxDist - curDist) > eps) && (maxDist < curDist) {
                maxDist = curDist
                topPos = setPoints[i]
                topLine = Line(vertex[leftPos],vertex[topPos])
            }
        }
        
        i+=1
    }
    
    let lt = Line(vertex[leftPos],vertex[topPos])
    // формируем множество точек, находящихся слева от прямой LT
    let s11 = GetPointsLeftByLine(vertex,setPoints,lt)
    var result = quickHull(vertex,leftPos,topPos, s11)
    
    let tr = Line(vertex[topPos],vertex[rightPos])
    // формируем множество точек, находящихся слева от прямой TR
    let s12 = GetPointsLeftByLine(vertex, setPoints,tr)
    result += quickHull(vertex, topPos, rightPos, s12)
    
    return result
}

public func quickHull(_ vertex: [Point]) -> [Int] {
    guard vertex.count >= 3 else {
        return []
    }
    // поиск самой левой и самой правой точки
    var leftPos = 0
    var rightPos = 0
    
    for i in [Int](1..<vertex.count) {
        if (fabs(vertex[i].x - vertex[leftPos].x) > eps) && (vertex[i].x < vertex[leftPos].x) {
            leftPos = i
        } else if (fabs(vertex[rightPos].x - vertex[i].x) > eps) && (vertex[rightPos].x < vertex[i].x) {
            rightPos = i
        }
    }
    
    let lr = Line(vertex[leftPos],vertex[rightPos])
    var s1 = [Int]() // точки выше прямой LR
    var s2 = [Int]() // точки ниже прямой LR
    for i in [Int](0..<vertex.count) {
        if (i != leftPos && i != rightPos)
        {
            if lr.isLeft(vertex[i]) {
                s1.append(i)
            } else if (lr.isRight(vertex[i])) {
                s2.append(i)
            }
        }
    }
    var result = quickHull(vertex, leftPos, rightPos, s1)
    result += quickHull(vertex, rightPos, leftPos, s2)
    
    return result
}
