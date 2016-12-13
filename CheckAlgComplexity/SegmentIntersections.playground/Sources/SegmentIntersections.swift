import Foundation

let eps = 10E-8
public struct Point: Hashable {
    public var x: Double
    public var y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    public var hashValue: Int {
        return Int(31.0*x + y*0.5)
    }
}

public struct Segment: Hashable {
    public var l: Point
    public var r: Point
    
    public init(l: Point, r: Point) {
        self.l = l
        self.r = r
    }
    
    public var hashValue: Int {
        return 31*l.hashValue + r.hashValue>>2
    }
}

public func ==(l: Segment, r: Segment) -> Bool {
    return l.l == r.l && l.r == r.r
}

public func ==(l: Point, r: Point) -> Bool {
    return l.x-r.x<=eps && l.y-r.y<=eps
}

func <(l: Segment, r: Segment) -> Bool {
    return false
}

enum Event: Hashable {
    case Left(Segment), Right(Segment), Intersection(Point, Segment, Segment)
    
    var hashValue: Int {
        switch self {
        case .Left(let segment): return segment.hashValue
        case .Right(let segment): return segment.hashValue
        case .Intersection(let point, _, _): return point.hashValue
        }
    }
    
    var anchorPoint: Point {
        switch self {
        case .Left(let segment): return segment.l
        case .Right(let segment): return segment.r
        case .Intersection(let point, _, _): return point
        }
    }
}

func ==(l: Event, r: Event) -> Bool {
    return l.hashValue == r.hashValue
}

func <(l: Event, r: Event) -> Bool {
    return l.anchorPoint < r.anchorPoint
}

infix operator >|<
func >|<(_ a: Segment, _ b: Segment) -> Bool {
    return intersect1d (a.l.x, a.r.x, b.l.x, b.r.x)
        && intersect1d (a.l.y, a.r.y, b.l.y, b.r.y)
        && vec (a.l, a.r, b.l) * vec (a.l, a.r, b.r) <= 0
        && vec (b.l, b.r, a.l) * vec (b.l, b.r, a.r) <= 0
}

public func segmentIntersection(_ input: [Segment]) -> [Point] {
    var events = Set<Event>()
    var result = [Point]()
    var context = Set<Segment>()
    
    input.forEach{
        events.insert(.Left($0))
        events.insert(.Right($0))
    }
    
    while let current = Array(events).sorted(by: <).first {
        if case .Left(let segment) = current {
            for item in context {
                if let intersectPoint = intersect(item.l, item.r, segment.l, segment.r) {
                    events.insert(.Intersection(intersectPoint.l, item, segment))
                }
            }
            
            context.insert(segment)
        } else if case .Right(let segment) = current {
            context.remove(segment)
        } else if case .Intersection(let point, _, _) = current {
            result.append(point)
        }
        events.remove(current)
    }
    
    return result
}


func intersect1d(_ l1: Double, _ r1: Double , _ l2: Double , _ r2: Double ) -> Bool {
    var _l1 = l1
    var _r1 = r1
    var _l2 = l2
    var _r2 = r2
    if (l1 > r1) { swap(&_l1, &_r1) }
    if (l2 > r2) { swap(&_l2, &_r2) }
    return max(_l1, _l2) <= min(_r1, _r2) + eps
}

func betw(_ l: Double, _ r: Double, _ x: Double) -> Bool {
    return min(l,r) <= x + eps && x <= max(l,r) + eps
}

func vec(_ a: Point, _ b: Point, _ c: Point) -> Int {
    let s = (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
    return abs(s)<eps ? 0 : (s>0 ? +1 : -1)
}

func det(_ a: Double, _ b: Double, _ c: Double, _ d: Double) -> Double {
    return a * d - b * c
}

func intersect(_ a: Point, _ b: Point, _ c: Point, _ d: Point) -> Segment? {
    if !intersect1d (a.x, b.x, c.x, d.x) || !intersect1d(a.y, b.y, c.y, d.y) {
        return nil
    }
    let m = line(a, b)
    let n = line(c, d)
    let zn = det(m.a, m.b, n.a, n.b)
    var _a = a
    var _b = b
    var _c = c
    var _d = d
    
    if abs(zn)<eps {
        if abs(m.dist(c))>eps || abs(n.dist(a))>eps { return nil }
        if _b<_a { swap(&_a, &_b) }
        if _d<_c { swap(&_c, &_d) }

        return Segment(l: max(_a, _c), r: min(_b, _d))
    } else {
        let x = -det(m.c, m.b, n.c, n.b) / zn
        let y = -det(m.a, m.c, n.a, n.c) / zn
        let condition = betw (a.x, b.x, x)
            && betw (a.y, b.y, y)
            && betw (c.x, d.x, x)
            && betw (c.y, d.y, y)
        return condition ? Segment(l: Point(x: x, y: y), r: Point(x: x, y: y)) : nil
    }
}

struct line {
    var a: Double
    var b: Double
    var c: Double
    
    init(_ p: Point, _ q: Point) {
        a = p.y - q.y
        b = q.x - p.x;
        c = -a * p.x - b * p.y;
        norm()
    }
    
    mutating func norm() {
        let z = sqrt (a*a + b*b)
        if (abs(z) > eps) {
            a /= z
            b /= z
            c /= z
        }
    }
    
    func dist(_ p: Point) -> Double {
        return a * p.x + b * p.y + c
    }
};

extension Point: Comparable {
    
    public static func <(l: Point, r: Point) -> Bool {
        return abs(l.x-r.x)==eps && l.y<r.y || l.x<r.x
    }
    
    public static func <=(l: Point, r: Point) -> Bool {
        return abs(l.x-r.x)==eps && l.y<=r.y || l.x<=r.x
    }
    
    public static func >=(l: Point, r: Point) -> Bool {
        return !(l<r)
    }
    
    public static func >(l: Point, r: Point) -> Bool {
        return !(l<=r)
    }
}
