//
//  CircularProgressView.swift
//  Quit The Nic
//
//  Created by Luke Stuart on 11/5/24.
//

import UIKit

class CircularProgressView: UIView {
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCircleLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCircleLayers()
    }

    private func setupCircleLayers() {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2, y: frame.size.height / 2),
                                        radius: (frame.size.width - 10) / 2,
                                        startAngle: -CGFloat.pi / 2,
                                        endAngle: 1.5 * CGFloat.pi,
                                        clockwise: true)

        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)

        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.systemBlue.cgColor
        progressLayer.lineWidth = 10
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }

    func setProgress(to progress: Float) {
        progressLayer.strokeEnd = CGFloat(progress)
    }
}
