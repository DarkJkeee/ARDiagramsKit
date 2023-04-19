//
//  BarChart.swift
//  
//
//  Created by Gleb Burstein on 07.03.2023.
//

import SceneKit
import SpriteKit

public class BarChart: SCNNode, Chart {
  private let values: [[Double]]
  private var barColors: [UIColor]

  private var seriesLabels: [String]?
  private var indexLabels: [String]?

  public var settings: ChartSettings = .init() {
    didSet {
      opacity = settings.opacity
      if let colors = settings.colors {
        barColors = colors
      }
    }
  }

  public var type: ChartType {
    .bar
  }

  public required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public init(
    values: [[Double]],
    barColors: [UIColor],
    seriesLabels: [String],
    indexLabels: [String]
  ) {
    self.values = values
    self.barColors = barColors
    self.seriesLabels = seriesLabels
    self.indexLabels = indexLabels
    super.init()
  }

  private var numberOfSeries: Int {
    return self.values.count
  }

  private var maxNumberOfIndices: Int? {
    return Array(0..<numberOfSeries).map({ values[$0].count }).max()
  }

  private var minAndMaxChartValues: (minValue: Double, maxValue: Double)? {
    var minValue = Double.greatestFiniteMagnitude
    var maxValue = Double.leastNormalMagnitude
    var didProcessValue = false

    for series in 0..<values.count {
      for index in 0..<values[series].count {
        let value = values[series][index]
        minValue = min(minValue, value)
        maxValue = max(maxValue, value)
        didProcessValue = true
      }
    }

    guard didProcessValue == true else {
      return nil
    }

    return (minValue, maxValue)
  }

  public func draw() {
    guard let maxNumberOfIndices = self.maxNumberOfIndices,
          let minValue = self.minAndMaxChartValues?.minValue,
          let maxValue = self.minAndMaxChartValues?.maxValue,
          minValue < maxValue else { return }
    let spaceBetweenLabels: Float = 0.2

    let sizeAvailableForBars = SCNVector3(
      x: settings.size.x * (1.0 - spaceBetweenLabels),
      y: settings.size.y,
      z: settings.size.z * (1.0 - spaceBetweenLabels)
    )
    let biggestValueRange = maxValue - minValue

    let barLength = self.seriesSize(withNumberOfSeries: numberOfSeries, zSizeAvailableForBars: sizeAvailableForBars.z)
    let barWidth = self.indexSize(withNumberOfIndices: maxNumberOfIndices, xSizeAvailableForBars: sizeAvailableForBars.x)
    let maxBarHeight = sizeAvailableForBars.y / Float(biggestValueRange)

    let xShift = settings.size.x * (spaceBetweenLabels - 0.5)
    let zShift = settings.size.z * (spaceBetweenLabels - 0.5)
    var previousZPosition: Float = 0.0

    for series in 0..<numberOfSeries {
      let zPosition = previousZPosition + barLength + barLength * (series == 0 ? 0 : 0.5)
      var previousXPosition: Float = 0.0

      for index in 0..<values[series].count {
        let value = values[series][index]
        let barHeight = Float(value) * maxBarHeight

        let barBox = SCNBox(
          width: CGFloat(barWidth),
          height: CGFloat(barHeight),
          length: CGFloat(barLength),
          chamferRadius: 0
        )
        let barNode = SCNNode(geometry: barBox)
        barNode.opacity = opacity

        let yPosition = 0.5 * Float(value) * Float(maxBarHeight)
        let startingYPosition = yPosition
        let xPosition = previousXPosition + barWidth + barWidth * (index == 0 ? 0 : 0.5)
        barNode.position = SCNVector3(
          x: xPosition + xShift, y: Float(startingYPosition), z: zPosition + zShift
        )

        let barMaterial = SCNMaterial()
        barMaterial.diffuse.contents = barColors[(series * values[series].count + index) % barColors.count]
        barMaterial.specular.contents = UIColor.white
        barNode.geometry?.firstMaterial = barMaterial

        self.addChildNode(barNode)

        if series == 0 {
          self.addLabel(forIndex: index, atXPosition: xPosition + xShift, withMaxHeight: barWidth)
        }
        previousXPosition = xPosition
      }

      self.addLabel(forSeries: series, atZPosition: zPosition + zShift, withMaxHeight: barLength)
      previousZPosition = zPosition
    }
  }

  private func seriesSize(withNumberOfSeries numberOfSeries: Int, zSizeAvailableForBars availableZSize: Float) -> Float {
    let totalGapCoefficient: Float = Array(0 ..< numberOfSeries).reduce(0, { (total, current) -> Float in
      total + 0.5
    })

    return availableZSize / (Float(numberOfSeries) + totalGapCoefficient)
  }

  private func indexSize(withNumberOfIndices numberOfIndices: Int, xSizeAvailableForBars availableXSize: Float) -> Float {
    let totalGapCoefficient: Float = Array(0 ..< numberOfIndices).reduce(0, { (total, current) -> Float in
      total + 0.5
    })

    return availableXSize / (Float(numberOfIndices) + totalGapCoefficient)
  }

  private func addLabel(forSeries series: Int, atZPosition zPosition: Float, withMaxHeight maxHeight: Float) {
    if let seriesLabels, series < seriesLabels.count {
      let seriesLabelNode = ARChartLabel(text: seriesLabels[series], backgroundColor: .clear)

      let unscaledLabelWidth = seriesLabelNode.boundingBox.max.x - seriesLabelNode.boundingBox.min.x
      let desiredLabelWidth = settings.size.x * 0.3
      let unscaledLabelHeight = seriesLabelNode.boundingBox.max.y - seriesLabelNode.boundingBox.min.y
      let labelScale = min(desiredLabelWidth / unscaledLabelWidth, maxHeight / unscaledLabelHeight)
      seriesLabelNode.scale = SCNVector3(labelScale, labelScale, labelScale)

      let zShift = 0.5 * maxHeight - (maxHeight - labelScale * unscaledLabelHeight)
      let position = SCNVector3(
        x: -0.7 * settings.size.x,
        y: 0.0,
        z: zPosition + zShift
      )
      seriesLabelNode.position = position
      seriesLabelNode.eulerAngles = SCNVector3(-0.5 * Float.pi, 0.0, 0.0)

      self.addChildNode(seriesLabelNode)
    }
  }

  private func addLabel(forIndex index: Int, atXPosition xPosition: Float, withMaxHeight maxHeight: Float) {
    if let indexLabels, index < indexLabels.count {
      let indexLabelNode = ARChartLabel(text: indexLabels[index], backgroundColor: .clear)

      let unscaledLabelWidth = indexLabelNode.boundingBox.max.x - indexLabelNode.boundingBox.min.x
      let desiredLabelWidth = settings.size.z * 0.3
      let unscaledLabelHeight = indexLabelNode.boundingBox.max.y - indexLabelNode.boundingBox.min.y
      let labelScale = min(desiredLabelWidth / unscaledLabelWidth, maxHeight / unscaledLabelHeight)
      indexLabelNode.scale = SCNVector3(labelScale, labelScale, labelScale)

      let xShift = (maxHeight - labelScale * unscaledLabelHeight) - 0.5 * maxHeight
      let position = SCNVector3(
        x: xPosition + xShift,
        y: 0.0,
        z: -0.7 * settings.size.z
      )
      indexLabelNode.position = position
      indexLabelNode.eulerAngles = SCNVector3(-0.5 * Float.pi, -0.5 * Float.pi, 0.0)

      self.addChildNode(indexLabelNode)
    }
  }
}
