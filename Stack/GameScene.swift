//
//  GameScene.swift
//  Stack
//
//  Created by Pedro Cacique on 18/11/19.
//  Copyright © 2019 Pedro Cacique. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var renderTime: TimeInterval = 0
    let changeTime: TimeInterval = 0.05
    
    var renderTime2: TimeInterval = 0
    let changeTime2: TimeInterval = 2
    
    let columns: Int = 20
    var columnSize: CGFloat = 0
    var columnSpace: CGFloat = 20
    
    var deltaX: CGFloat = 10
    let yBorder: CGFloat = 40
    var xBorder: CGFloat = 40
    let numYdiv: Int = 20
    let yProb: Int = 50
    
    let bgColor: UIColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1)
    let strokeColor: UIColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
    
    var colors: [UIColor] = [ UIColor(red: 209/255, green: 196/255, blue: 131/255, alpha: 1),
                              UIColor(red: 104/255, green: 175/255, blue: 200/255, alpha: 1),
                              UIColor(red: 239/255, green: 130/255, blue: 177/255, alpha: 1),
                              UIColor(red: 137/255, green: 191/255, blue: 179/255, alpha: 1)
    ]
    var colorCount: Int = 0
    
    var stacks:[Stack] = []
    var targets:[Stack] = []
    var isAnimating:Bool = false
    var animationSteps:Int = 5
    var animationCount: Int = 0
    
    override func didMove(to view: SKView) {
        self.backgroundColor = bgColor
        
        columnSize = (self.size.width - 2 * xBorder) / CGFloat(2 * columns + 1)
        columnSpace = columnSize
        deltaX = columnSpace / 2
        setup()
        draw()
        isAnimating = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
    }
    
    @objc func doubleTapped() {
        setup()
    }
    
    func setup(){
        stacks = []
        targets = []
        for i in 0..<columns{
            stacks.append( generateStack(i: i, true) )
            targets.append( generateStack(i: i, false) )
        }
    }
    
    func generateNewTargets(){
        targets = []
        for i in 0..<columns{
            targets.append( generateStack(i: i, false) )
        }
        isAnimating = true
    }
    
    func generateStack(i:Int, _ isUniform:Bool) -> Stack{
        let p0 = getPoints(x: xBorder + columnSize + CGFloat(i) * (columnSize + columnSpace), isUniform: isUniform)
        let p1 = getPoints(x: xBorder + columnSize + CGFloat(i) * (columnSize + columnSpace) + columnSpace, isUniform: isUniform)
        let p2 = getIntermediatePoints(p0, segments: i+1)
        let p3 = getIntermediatePoints(p1, segments: i+1)
        let stack = Stack(p0: p0, p1: p1, p2: p2, p3: p3)
        return stack
    }
    
    func draw(){
        removeAllChildren()
        for s in stacks{
            drawStack(s)
        }
    }
    
    func drawStack(_ stack:Stack){
        drawHorizontalLines(stack.p2, stack.p3, 0.8, colors[colorCount])
        drawVerticalLines(stack.p0, 1, strokeColor)
        drawVerticalLines(stack.p1, 1, strokeColor)
        drawHorizontalLines(stack.p0, stack.p1, 1, strokeColor)
    }
    
    func getPoints(x: CGFloat, isUniform: Bool = false) -> [CGPoint]{
        let totalHeight = self.frame.height - 2 * yBorder
        
        var points: [CGPoint] = []
        points.append(CGPoint(x: x, y: yBorder))
        let dy = totalHeight/CGFloat(numYdiv - 1)
        var py = points[0].y
        
        for _ in 0...numYdiv-2 {
            points.append(CGPoint(x:x + ((isUniform) ? 0 : CGFloat.random(in: -deltaX ... deltaX)),
                                  y: (isUniform) ? py : CGFloat.random(in: py...py+dy)) )
            py += dy
        }
        points.append(CGPoint(x:x, y:self.frame.height - yBorder))
        return points.sorted {$0.y < $1.y}
    }
    
    func drawVerticalLines(_ points: [CGPoint], _ lineWidth:CGFloat = 1, _ color:UIColor = .black){
        if points.count > 1 {
            let path:CGMutablePath = CGMutablePath()
            path.move(to: points[0])
            for p in 1..<points.count{
                path.addLine(to: points[p])
            }
            
            let shape = SKShapeNode()
            shape.path = path
            shape.strokeColor = color
            shape.lineWidth = lineWidth
            shape.isAntialiased = false
            
            self.addChild(shape)
        }
    }
    
    func getIntermediatePoints(_ points: [CGPoint], segments:Int) -> [CGPoint]{
        var resultPoints: [CGPoint] = []
        for i in 0..<points.count-1 {
            let seg = RectSegment(p0: points[i], p1: points[i+1])
            let step = (points[i+1].y - points[i].y)/CGFloat(segments)
            var y = points[i].y + step
            for _ in 0..<segments-1 {
                resultPoints.append( seg.getPoint(y: y) )
                y += step
            }
        }
        return resultPoints
    }
    
    func drawHorizontalLines(_ points1: [CGPoint], _ points2: [CGPoint], _ lineWidth:CGFloat = 1, _ color:UIColor = .black){
        if points1.count != points2.count || points1.count <= 1 {
            return
        }
        
        let path:CGMutablePath = CGMutablePath()
        for p in 0..<points1.count{
            path.move(to: points1[p])
            path.addLine(to: points2[p])
        }
        
        let shape = SKShapeNode()
        shape.path = path
        shape.strokeColor = color
        shape.lineWidth = lineWidth
        shape.isAntialiased = false
        
        self.addChild(shape)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if currentTime > renderTime {
            
            if isAnimating {
                for i in 0..<stacks.count {
                    for j in 0..<stacks[i].p0.count {
                        let dx0 = (targets[i].p0[j].x - stacks[i].p0[j].x) / CGFloat(animationSteps)
                        let dy0 = (targets[i].p0[j].y - stacks[i].p0[j].y) / CGFloat(animationSteps)
                        stacks[i].p0[j].x += dx0
                        stacks[i].p0[j].y += dy0

                        let dx1 = (targets[i].p1[j].x - stacks[i].p1[j].x) / CGFloat(animationSteps)
                        let dy1 = (targets[i].p1[j].y - stacks[i].p1[j].y) / CGFloat(animationSteps)
                        stacks[i].p1[j].x += dx1
                        stacks[i].p1[j].y += dy1

                        stacks[i].p2 = getIntermediatePoints(stacks[i].p0, segments: i+1)
                        stacks[i].p3 = getIntermediatePoints(stacks[i].p1, segments: i+1)
                    }
                }
                animationCount += 1
                if animationCount == animationSteps {
                    isAnimating = false
                    animationCount = 0
                    generateNewTargets()
                }
                draw()
            }
            
            renderTime = currentTime + changeTime
        }
        if currentTime > renderTime2 {
            colorCount += 1
            if colorCount == colors.count {
                colorCount = 0
            }
            renderTime2 = currentTime + changeTime2
        }
    }
}

struct Stack {
    var p0:[CGPoint]
    var p1:[CGPoint]
    var p2:[CGPoint]
    var p3:[CGPoint]
}
