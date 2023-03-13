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
  private let barColors: [UIColor]

  private var seriesLabels: [String]?
  private var indexLabels: [String]?

  public var size: SCNVector3!

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
  private var minValue: Double?
  private var maxValue: Double?

  public func draw() {
    guard let maxNumberOfIndices = self.maxNumberOfIndices, let size = self.size,
          let minValue = self.minValue ?? self.minAndMaxChartValues?.minValue,
          let maxValue = self.maxValue ?? self.minAndMaxChartValues?.maxValue,
          minValue < maxValue else { return }

    let spaceForSeriesLabels: Float = 0.2
    let spaceForIndexLabels: Float = 0.2

    let sizeAvailableForBars = SCNVector3(
      x: size.x * (1.0 - spaceForSeriesLabels),
      y: size.y,
      z: size.z * (1.0 - spaceForIndexLabels)
    )
    let biggestValueRange = maxValue - minValue

    let barLength = self.seriesSize(withNumberOfSeries: numberOfSeries, zSizeAvailableForBars: sizeAvailableForBars.z)
    let barWidth = self.indexSize(withNumberOfIndices: maxNumberOfIndices, xSizeAvailableForBars: sizeAvailableForBars.x)
    let maxBarHeight = sizeAvailableForBars.y / Float(biggestValueRange)

    let xShift = size.x * (spaceForSeriesLabels - 0.5)
    let zShift = size.z * (spaceForIndexLabels - 0.5)
    var previousZPosition: Float = 0.0

    for series in 0..<numberOfSeries {
      let zPosition = self.zPosition(forSeries: series, previousZPosition, barLength)
      var previousXPosition: Float = 0.0

      for index in 0..<values[series].count {
        let value = values[series][index]
        let barHeight = Float(value) * maxBarHeight
        let startingBarHeight = barHeight
        let startingBarOpacity = opacity

        let barChamferRadius = min(barLength, barWidth) * 0.0
        let barBox = SCNBox(
          width: CGFloat(barWidth),
          height: CGFloat(startingBarHeight),
          length: CGFloat(barLength),
          chamferRadius: CGFloat(barChamferRadius)
        )
        let barNode = SCNNode(geometry: barBox)
        barNode.opacity = CGFloat(startingBarOpacity)

        let yPosition = 0.5 * Float(value) * Float(maxBarHeight)
        let startingYPosition = yPosition
        let xPosition = self.xPosition(forIndex: index, previousXPosition, barWidth)
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

  private func xPosition(forIndex index: Int, _ previousIndexXPosition: Float, _ indexSize: Float) -> Float {
    let gapSize: Float = index == 0 ? 0.0 : 0.5

    return previousIndexXPosition + indexSize + indexSize * gapSize
  }

  private func zPosition(forSeries series: Int, _ previousSeriesZPosition: Float, _ seriesSize: Float) -> Float {
    let gapSize: Float = series == 0 ? 0.0 : 0.5

    return previousSeriesZPosition + seriesSize + seriesSize * gapSize
  }

  private func addLabel(forSeries series: Int, atZPosition zPosition: Float, withMaxHeight maxHeight: Float) {
    if let seriesLabelText = seriesLabels?[series] {
      let seriesLabel = SCNText(string: seriesLabelText, extrusionDepth: 0.0)
      seriesLabel.font = UIFont.systemFont(ofSize: 10.0)
      seriesLabel.firstMaterial!.isDoubleSided = true
      seriesLabel.firstMaterial!.diffuse.contents = UIColor.black

      let backgroundColor = UIColor.clear
      let seriesLabelNode = ARChartLabel(text: seriesLabel, type: .series, id: series, backgroundColor: backgroundColor)

      let unscaledLabelWidth = seriesLabelNode.boundingBox.max.x - seriesLabelNode.boundingBox.min.x
      let desiredLabelWidth = size.x * 0.2
      let unscaledLabelHeight = seriesLabelNode.boundingBox.max.y - seriesLabelNode.boundingBox.min.y
      let labelScale = min(desiredLabelWidth / unscaledLabelWidth, maxHeight / unscaledLabelHeight)
      seriesLabelNode.scale = SCNVector3(labelScale, labelScale, labelScale)

      let zShift = 0.5 * maxHeight - (maxHeight - labelScale * unscaledLabelHeight)
      let position = SCNVector3(
        x: -0.5 * size.x,
        y: 0.0,
        z: zPosition + zShift
      )
      seriesLabelNode.position = position
      seriesLabelNode.eulerAngles = SCNVector3(-0.5 * Float.pi, 0.0, 0.0)

      self.addChildNode(seriesLabelNode)
    }
  }

  private func addLabel(forIndex index: Int, atXPosition xPosition: Float, withMaxHeight maxHeight: Float) {
    if let indexLabelText = indexLabels?[index] {
      let indexLabel = SCNText(string: indexLabelText, extrusionDepth: 0.0)
      indexLabel.font = UIFont.systemFont(ofSize: 10.0)
      indexLabel.firstMaterial!.isDoubleSided = true
      indexLabel.firstMaterial!.diffuse.contents = UIColor.black

      let backgroundColor = UIColor.clear
      let indexLabelNode = ARChartLabel(text: indexLabel, type: .index, id: index, backgroundColor: backgroundColor)

      let unscaledLabelWidth = indexLabelNode.boundingBox.max.x - indexLabelNode.boundingBox.min.x
      let desiredLabelWidth = size.z * 0.2
      let unscaledLabelHeight = indexLabelNode.boundingBox.max.y - indexLabelNode.boundingBox.min.y
      let labelScale = min(desiredLabelWidth / unscaledLabelWidth, maxHeight / unscaledLabelHeight)
      indexLabelNode.scale = SCNVector3(labelScale, labelScale, labelScale)

      let xShift = (maxHeight - labelScale * unscaledLabelHeight) - 0.5 * maxHeight
      let position = SCNVector3(
        x: xPosition + xShift,
        y: 0.0,
        z: -0.5 * size.z
      )
      indexLabelNode.position = position
      indexLabelNode.eulerAngles = SCNVector3(-0.5 * Float.pi, -0.5 * Float.pi, 0.0)

      self.addChildNode(indexLabelNode)
    }
  }
}
