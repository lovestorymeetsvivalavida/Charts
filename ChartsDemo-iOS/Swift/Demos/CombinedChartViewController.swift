//
//  CombinedChartViewController.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

#if canImport(UIKit)
    import UIKit
#endif
import Charts
#if canImport(UIKit)
    import UIKit
#endif

private let ITEM_COUNT = 12

class CombinedChartViewController: DemoBaseViewController {
    @IBOutlet var chartView: CombinedChartView!
    
    let months = ["Jan", "Feb", "Mar",
                  "Apr", "May", "Jun",
                  "Jul", "Aug", "Sep",
                  "Oct", "Nov", "Dec"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Combined Chart"
        self.options = [.toggleLineValues,
                        .toggleBarValues,
                        .saveToGallery,
                        .toggleData,
                        .toggleBarBorders,
                        .removeDataSet]
        
        chartView.delegate = self
        
        chartView.chartDescription.enabled = false
        
        chartView.drawBarShadowEnabled = false
        chartView.highlightFullBarEnabled = true
        
        chartView.doubleTapToZoomEnabled = false
        chartView.highlightPerTapEnabled = false
        chartView.highlightPerLongPressEnabled = true
        
        chartView.drawOrder = [DrawOrder.bar.rawValue,
                               DrawOrder.bubble.rawValue,
                               DrawOrder.candle.rawValue,
                               DrawOrder.line.rawValue,
                               DrawOrder.scatter.rawValue
        ]
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.axisMinimum = 0
        xAxis.granularity = 1
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = false
        xAxis.valueFormatter = self
        
        let marker = XYMarkerView(color: UIColor(white: 180/250, alpha: 1),
                                  font: .systemFont(ofSize: 12),
                                  textColor: .black,
                                  insets: UIEdgeInsets(top: 7, left: 10, bottom: 8, right: 10),
                                  xAxisValueFormatter: chartView.xAxis.valueFormatter!)
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 164, height: 40)
        chartView.marker = marker
        
        let legend = chartView.legend
        legend.wordWrapEnabled = true
        legend.horizontalAlignment = .left
        legend.verticalAlignment = .top
        legend.orientation = .horizontal
        legend.drawInside = false
        let legendEntry0 = LegendEntry(label: "盈利")
        legendEntry0.form = .square
        legendEntry0.formColor = .blue
        let legendEntry1 = LegendEntry(label: "亏损")
        legendEntry1.form = .square
        legendEntry1.formColor = .green
        legend.setCustom(entries: [legendEntry0, legendEntry1])
//        chartView.legend = l

        let rightAxis = chartView.rightAxis
        rightAxis.axisMinimum = 0
        rightAxis.drawAxisLineEnabled = false
        rightAxis.drawLabelsEnabled = false
        
        
        let leftAxis = chartView.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.drawAxisLineEnabled = false
        
        self.updateChartData()
    }
    
    override func updateChartData() {
        if self.shouldHideData {
            chartView.data = nil
            return
        }
        
        self.setChartData()
    }
    
    func setChartData() {
        let data = CombinedChartData()
        data.xLabelAlias = "时间"
        data.lineData = generateLineData()
        data.lineData.isHighlightEnabled = false
        data.barData = generateBarData()
//        data.bubbleData = generateBubbleData()
//        data.scatterData = generateScatterData()
//        data.candleData = generateCandleData()
        
        chartView.xAxis.axisMaximum = data.xMax + 0.5
        
        chartView.data = data
    }
    
    override func optionTapped(_ option: Option) {
        switch option {
        case .toggleLineValues:
            for set in chartView.data! {
                if let set = set as? LineChartDataSet {
                    set.drawValuesEnabled = !set .drawValuesEnabled
                    
                }
            }
            chartView.setNeedsDisplay()
            
        case .toggleBarValues:
            for set in chartView.data! {
                if let set = set as? BarChartDataSet {
                    set.drawValuesEnabled = !set .drawValuesEnabled
                }
            }
            chartView.setNeedsDisplay()
            
        case .removeDataSet:
            let rnd = Int(arc4random_uniform(UInt32(chartView.data!.dataSetCount)))
            chartView.data?.removeDataSet(chartView.data![rnd])
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
            
        default:
            super.handleOption(option, forChartView: chartView)
        }
    }
    
    func generateLineData() -> LineChartData {
        let entries = (0..<ITEM_COUNT).map { (i) -> ChartDataEntry in
            return ChartDataEntry(x: Double(i) + 0.5, y: Double(arc4random_uniform(15) + 5))
        }
        
        let set = LineChartDataSet(entries: entries, label: "Line DataSet")
        set.setColor(UIColor(red: 240/255, green: 238/255, blue: 70/255, alpha: 1))
        set.lineWidth = 2.5
        set.setCircleColor(UIColor(red: 240/255, green: 238/255, blue: 70/255, alpha: 1))
        set.circleRadius = 5
        set.circleHoleRadius = 2.5
        set.fillColor = UIColor(red: 240/255, green: 238/255, blue: 70/255, alpha: 1)
        set.mode = .cubicBezier
        set.drawValuesEnabled = true
        set.valueFont = .systemFont(ofSize: 10)
        set.valueTextColor = UIColor(red: 240/255, green: 238/255, blue: 70/255, alpha: 1)
        set.axisDependency = .left
        
        return LineChartData(dataSet: set)
    }
    
    func generateBarData() -> BarChartData {
        let entries1 = (0..<ITEM_COUNT).map { (i) -> BarChartDataEntry in
            return BarChartDataEntry(x: Double(i), y: Double(arc4random_uniform(25) + 25))
        }
        let entries2 = (0..<ITEM_COUNT).map { (i) -> BarChartDataEntry in
            return BarChartDataEntry(x: Double(i), yValues: [Double(arc4random_uniform(13) + 12)])
        }
        
        let set1 = BarChartDataSet(entries: entries1, label: "Bar 1")
        set1.setColor(UIColor(red: 60/255, green: 220/255, blue: 78/255, alpha: 1))
        set1.valueTextColor = UIColor(red: 60/255, green: 220/255, blue: 78/255, alpha: 1)
        set1.valueFont = .systemFont(ofSize: 10)
        set1.axisDependency = .left
        set1.form = .circle
        
        let set2 = BarChartDataSet(entries: entries2, label: "Bar 2")
        set2.setColor(UIColor(red: 61/255, green: 165/255, blue: 255/255, alpha: 1))
        set2.valueTextColor = UIColor(red: 61/255, green: 165/255, blue: 255/255, alpha: 1)
        set2.valueFont = .systemFont(ofSize: 10)
        set2.axisDependency = .left
        set2.form = .square
        
        let groupSpace = 0.06
        let barSpace = 0.02 // x2 dataset
        let barWidth = 0.45 // x2 dataset
        // (0.45 + 0.02) * 2 + 0.06 = 1.00 -> interval per "group"
        
        let data: BarChartData = [set1, set2]
        data.barWidth = barWidth
        
        // make this BarData object grouped
        data.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
        
        return data
    }
    
    func generateScatterData() -> ScatterChartData {
        let entries = stride(from: 0.0, to: Double(ITEM_COUNT), by: 0.5).map { (i) -> ChartDataEntry in
            return ChartDataEntry(x: i+0.25, y: Double(arc4random_uniform(10) + 55))
        }
        
        let set = ScatterChartDataSet(entries: entries, label: "Scatter DataSet")
        set.colors = ChartColorTemplates.material()
        set.scatterShapeSize = 4.5
        set.drawValuesEnabled = false
        set.valueFont = .systemFont(ofSize: 10)
        
        return ScatterChartData(dataSet: set)
    }
    
    func generateCandleData() -> CandleChartData {
        let entries = stride(from: 0, to: ITEM_COUNT, by: 2).map { (i) -> CandleChartDataEntry in
            return CandleChartDataEntry(x: Double(i+1), shadowH: 90, shadowL: 70, open: 85, close: 75)
        }
        
        let set = CandleChartDataSet(entries: entries, label: "Candle DataSet")
        set.setColor(UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1))
        set.decreasingColor = UIColor(red: 142/255, green: 150/255, blue: 175/255, alpha: 1)
        set.shadowColor = .darkGray
        set.valueFont = .systemFont(ofSize: 10)
        set.drawValuesEnabled = false
        
        return CandleChartData(dataSet: set)
    }
    
    func generateBubbleData() -> BubbleChartData {
        let entries = (0..<ITEM_COUNT).map { (i) -> BubbleChartDataEntry in
            return BubbleChartDataEntry(x: Double(i) + 0.5,
                                        y: Double(arc4random_uniform(10) + 105),
                                        size: CGFloat(arc4random_uniform(50) + 105))
        }
        
        let set = BubbleChartDataSet(entries: entries, label: "Bubble DataSet")
        set.setColors(ChartColorTemplates.vordiplom(), alpha: 1)
        set.valueTextColor = .white
        set.valueFont = .systemFont(ofSize: 10)
        set.drawValuesEnabled = true
        
        return BubbleChartData(dataSet: set)
    }
}

extension CombinedChartViewController: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return months[Int(value) % months.count]
    }
}
