//
//  XYMarkerView.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import Foundation
import Charts
#if canImport(UIKit)
    import UIKit
#endif

public class XYMarkerView: BalloonMarker {
    public var xAxisValueFormatter: AxisValueFormatter
    fileprivate var yFormatter = NumberFormatter()
    
    fileprivate var labels: [(String, String)]?
    
    public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets,
                xAxisValueFormatter: AxisValueFormatter) {
        self.xAxisValueFormatter = xAxisValueFormatter
        yFormatter.minimumFractionDigits = 1
        yFormatter.maximumFractionDigits = 1
        super.init(color: color, font: font, textColor: textColor, insets: insets)
    }
    
    public override func draw(context: CGContext, point: CGPoint)
    {
        guard let labels = labels else { return }
        
        let offset = self.offsetForDrawing(atPoint: point)
        let size = self.size
        
        var rect = CGRect(
            origin: CGPoint(
                x: point.x + offset.x,
                y: point.y + offset.y),
            size: size)
        rect.origin.x -= size.width / 2.0
        rect.origin.y -= size.height
        
        context.saveGState()

        context.setFillColor(color.cgColor)

        let clipPath: CGPath = UIBezierPath(roundedRect: rect, byRoundingCorners: [.allCorners], cornerRadii: CGSize(width: 6.0, height: 6.0)).cgPath
        context.addPath(clipPath)
        context.setFillColor(UIColor.darkGray.cgColor)
        
        context.closePath()
        context.fillPath()
        
        rect.origin.x += self.insets.left
        if offset.y > 0 {
            rect.origin.y += self.insets.top// + arrowSize.height
        } else {
            rect.origin.y += self.insets.top
        }

        rect.size.width -= self.insets.left + self.insets.right
        rect.size.height -= self.insets.top + self.insets.bottom
        
        UIGraphicsPushContext(context)
        
        for i in 0..<labels.count {
            let label = labels[i]
            let lineHeight = label.0.size(withAttributes: drawAttributes).height
            
            paragraphStyle?.alignment = .left
            drawAttributes[.paragraphStyle] = paragraphStyle
            label.0.draw(at: CGPoint(x: rect.origin.x, y: rect.origin.y + (lineHeight + 5.0) * CGFloat(i)), withAttributes: drawAttributes)
            
            paragraphStyle?.alignment = .right
            drawAttributes[.paragraphStyle] = paragraphStyle
            label.1.draw(in: CGRect(x: rect.origin.x, y: rect.origin.y + 20.0 * CGFloat(i), width: rect.width, height: 20), withAttributes: drawAttributes)
        }
        
        UIGraphicsPopContext()
        
        context.restoreGState()
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight, data: Any? = nil) {
        if let data = data as? CombinedChartData {
            var labels: [(String, String)] = []
            labels.append((data.xLabelAlias, xAxisValueFormatter.stringForValue(entry.x, axis: XAxis())))
            var entryIndex = -1
            for dataSet in data.dataSets {
                entryIndex = dataSet.entryIndex(entry: entry)
                if entryIndex >= 0 {
                    break
                }
            }
            for dataSet in data.dataSets {
                if let e = dataSet.entryForIndex(entryIndex) {
                    labels.append((dataSet.label ?? "" , "\(e.y)"))
                }
            }
        
            setLabels(labels: labels)
            return
        }
        
        let string = "x: "
            + xAxisValueFormatter.stringForValue(entry.x, axis: XAxis())
            + ", y: "
            + yFormatter.string(from: NSNumber(floatLiteral: entry.y))!
        setLabel(string)
    }
    
    func setLabels(labels: [(String, String)]) {
        self.labels = labels
        
        var labelsWithLineBreak: String = ""
        
        for i in 0..<labels.count {
            let label = labels[i]
            labelsWithLineBreak += "\(label.0)  \(label.1)"
            
            if i < labels.count - 1 {
                labelsWithLineBreak += "\n"
            }
        }
        
        drawAttributes.removeAll()
        drawAttributes[.font] = self.font
        paragraphStyle?.lineSpacing = 5.0
        drawAttributes[.paragraphStyle] = paragraphStyle
        drawAttributes[.foregroundColor] = self.textColor
        
        labelSize = labelsWithLineBreak.size(withAttributes: drawAttributes)
        
        var size = CGSize()
        size.width = labelSize.width + self.insets.left + self.insets.right
        size.height = labelSize.height + self.insets.top + self.insets.bottom
        size.width = max(minimumSize.width, size.width)
        size.height = max(minimumSize.height, size.height)
        self.size = size
    }
}
