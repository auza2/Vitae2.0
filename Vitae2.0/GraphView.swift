//
//  GraphView.swift
//  Vitae2.0
//
//  Created by Jamie Auza on 4/3/18.
//  Copyright © 2018 Jamie Auza. All rights reserved.
//

import UIKit

protocol graphViewDataSource{
    func numberOfColumns(_ graphView: GraphView) -> Int
    func columnForPoint(_ graphView: GraphView, _ dataIndex:Int) -> Int
    
    func numberOfPoints(_ graphView: GraphView) -> Int
    func valueForPoint(_ dataIndex:Int) -> Int
    
    func maxPointValue() -> Int
    func startDate() -> Date
    func endDate() -> Date
}

@IBDesignable class GraphView: UIView {
    @IBInspectable var startColor: UIColor = .red
    @IBInspectable var endColor: UIColor = .green
    weak var delegate: History!
    var indexPath = IndexPath()
    
    private struct Constants {
        static let cornerRadiusSize = CGSize(width: 8.0, height: 8.0)
        static let margin: CGFloat = 40.0
        static let topBorder: CGFloat = 60
        static let bottomBorder: CGFloat = 50
        static let colorAlpha: CGFloat = 0.3
        static let circleDiameter: CGFloat = 5.0
    }
    
    override func draw(_ rect: CGRect) {
        // Gradient
        layer.cornerRadius = 10
        layer.masksToBounds = true
        let context = UIGraphicsGetCurrentContext()!
        let colors = [startColor.cgColor, endColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)!
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: bounds.height)
        context.drawLinearGradient(gradient,
                                   start: startPoint,
                                   end: endPoint,
                                   options: [])
        // Data point values
        
        // Points
        let width = rect.width
        let height = rect.height

        print("rect width: \(width)")
        let graphWidth = width - 2*Constants.margin
        let numColumns = delegate.numberOfColumns(self)
        print("number of columns: \(numColumns)")
        let xPoint = { (column: Int) -> CGFloat in
            let spacing = graphWidth/CGFloat(numColumns)
            print("spacing width: \(spacing) | \(numColumns)")
            return CGFloat(column)*spacing + Constants.margin
        }

        let graphHeight = height - Constants.topBorder - Constants.bottomBorder
        let maxYValue = delegate.maxPointValue()
        let yPoint = { (graphPoint: Int) -> CGFloat in
            let y = CGFloat(graphPoint) / CGFloat(maxYValue) * graphHeight
            return graphHeight + Constants.topBorder - y
        }

        // Drawing the line
        UIColor.white.setFill()
        UIColor.white.setStroke()

        let graphPath = UIBezierPath()
        let numberOfPoint = delegate.numberOfPoints(self)
        
        let firstPoint = CGPoint(x: xPoint(0), y: yPoint(delegate.valueForPoint(0)))
        print(" First point - \(firstPoint) | X: \(xPoint(0)) Y: \(delegate.valueForPoint(0))")
        graphPath.move(to:firstPoint)
        
        for i in 1..<numberOfPoint {
            let column = delegate.columnForPoint(self, i)
            let value = delegate.valueForPoint(i)
            let calculatedPoint = CGPoint(x: xPoint(column), y: yPoint(value))
            print("\(calculatedPoint) | X: \(xPoint(column)) Y: \(value)")
            let nextPoint = calculatedPoint
            graphPath.addLine(to: nextPoint)
        }

        graphPath.stroke()
        
        //Create the clipping path for the graph gradient
        
        //1 - save the state of the context (commented out for now)
        context.saveGState()
        
        //2 - make a copy of the path
        let clippingPath = graphPath.copy() as! UIBezierPath
        
        //3 - add lines to the copied path to complete the clip area
        let column = delegate.columnForPoint(self, numberOfPoint-1)
        clippingPath.addLine(to: CGPoint(x: xPoint(column), y:height))
        clippingPath.addLine(to: CGPoint(x:xPoint(0), y:height))
        clippingPath.close()
        
        //4 - add the clipping path to the context
        clippingPath.addClip()
        
        //5 - check clipping path - temporary code
        let highestYPoint = yPoint(maxYValue)
        let graphStartPoint = CGPoint(x: Constants.margin, y: highestYPoint)
        let graphEndPoint = CGPoint(x: Constants.margin, y: bounds.height)
        
        context.drawLinearGradient(gradient, start: graphStartPoint, end: graphEndPoint, options: [])
        context.restoreGState()
        graphPath.lineWidth = 2.0
        graphPath.stroke()
        
        //Draw the circles on top of the graph stroke
        for i in 0..<numberOfPoint {
            let column = delegate.columnForPoint(self, i)
            let value = delegate.valueForPoint(i)
            var calculatedPoint = CGPoint(x: xPoint(column), y: yPoint(value))
//            var point = CGPoint(x: columnXPoint(i), y: columnYPoint(graphPoints[i]))
            calculatedPoint.x -= Constants.circleDiameter / 2
            calculatedPoint.y -= Constants.circleDiameter / 2
            
            let circle = UIBezierPath(ovalIn: CGRect(origin: calculatedPoint, size: CGSize(width: Constants.circleDiameter, height: Constants.circleDiameter)))
            circle.fill()
        }
        
        //Draw horizontal graph lines on the top of everything
        let linePath = UIBezierPath()
        
        //top line
        linePath.move(to: CGPoint(x: Constants.margin, y: Constants.topBorder))
        linePath.addLine(to: CGPoint(x: width - Constants.margin, y: Constants.topBorder))
        
        //center line
        linePath.move(to: CGPoint(x: Constants.margin, y: graphHeight/2 + Constants.topBorder))
        linePath.addLine(to: CGPoint(x: width - Constants.margin, y: graphHeight/2 + Constants.topBorder))
        
        //bottom line
        linePath.move(to: CGPoint(x: Constants.margin, y:height - Constants.bottomBorder))
        linePath.addLine(to: CGPoint(x:  width - Constants.margin, y: height - Constants.bottomBorder))
        let color = UIColor(white: 1.0, alpha: Constants.colorAlpha)
        color.setStroke()
        
        linePath.lineWidth = 1.0
        linePath.stroke()
        
        // Adding UILabel for max and min
        let maxLabel = UILabel(frame: CGRect(x: width - Constants.margin,y: Constants.topBorder - 10,width: 40,height: 20))
        maxLabel.textColor = UIColor.white
        maxLabel.textAlignment = .left
        maxLabel.text = "\(maxYValue)"
        addSubview(maxLabel)
        
        let minLabel = UILabel(frame: CGRect(x: width - Constants.margin,y: height - Constants.bottomBorder - 10,width: 40,height: 20))
        minLabel.textColor = UIColor.white
        minLabel.textAlignment = .left
        minLabel.text = "0"
        addSubview(minLabel)
    }
}
