import UIKit
import DGCharts

class OverviewViewController: UIViewController {
    private let lineChartView = LineChartView()
    var usageData: [Int] = [10, 20, 15, 30, 40, 35, 25] // Example data

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white // Set a background color for visibility
        setupChartView()
        setData()
    }

    private func setupChartView() {
        lineChartView.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 300)
        lineChartView.noDataText = "No data available"
        
        // Customize appearance to match Puff Count style
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.rightAxis.enabled = false
        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.leftAxis.axisMaximum = 50 // Adjust based on data
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        
        view.addSubview(lineChartView)
    }

    private func setData() {
        let values = usageData.enumerated().map { (index, usage) -> ChartDataEntry in
            return ChartDataEntry(x: Double(index), y: Double(usage))
        }

        let dataSet = LineChartDataSet(entries: values, label: "Weekly Usage")
        dataSet.colors = [.systemBlue]
        dataSet.circleColors = [.systemBlue]
        dataSet.circleRadius = 4
        dataSet.lineWidth = 2
        dataSet.mode = .cubicBezier // Smooth curved line

        let data = LineChartData(dataSet: dataSet)
        lineChartView.data = data
    }
}
