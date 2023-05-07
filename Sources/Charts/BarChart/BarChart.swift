//
//  BarChart.swift
//  
//
//  Created by Gleb Burstein on 07.03.2023.
//

import SceneKit

import Models

public final class BarChart: SCNNode, Chart {
  public var chartModel: ChartModel? {
    didSet {
      if let model = chartModel?.barChartModel {
        self.model = model
      }
    }
  }

  private var model: BarChartModel
  private var platformNode: SCNNode?
  private var highlightedBarNode: Bar?

  public required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public init(model: BarChartModel) {
    self.model = model
    super.init()
  }

  public func draw() {
    var minValue = Double.greatestFiniteMagnitude
    var maxValue = Double.leastNormalMagnitude

    for series in 0..<model.values.count {
      for index in 0..<model.values[series].count {
        minValue = min(minValue, model.values[series][index])
        maxValue = max(maxValue, model.values[series][index])
      }
    }
    guard let maxNumberOfIndexes = Array(0..<model.values.count).map({ model.values[$0].count }).max(),
          model.values.count > 0, minValue < maxValue else { return }

    let totalGapForSeries = getTotalGap(for: model.values.count)
    let totalGapForIndexes = getTotalGap(for: maxNumberOfIndexes)

    let platformNode = Platform(
      width: CGFloat(model.size.x),
      length: CGFloat(model.size.z)
    )

    let barWidth = model.size.x / (Float(maxNumberOfIndexes) + totalGapForIndexes)
    let maxBarHeight = model.size.y / Float(maxValue - minValue)
    let barLength = model.size.z / (Float(model.values.count) + totalGapForSeries)

    let shiftX = model.size.x / -2
    let shiftZ = model.size.z / -2

    var previousZ: Float = 0.0
    for series in 0..<model.values.count {
      let positionZ = previousZ + barLength + barLength * (series == 0 ? 0 : 0.5)
      var previousX: Float = 0.0
      
      for index in 0..<model.values[series].count {
        let value = Float(model.values[series][index]) * maxBarHeight

        let barNode = Bar(
          width: CGFloat(barWidth),
          height: CGFloat(value),
          length: CGFloat(barLength),
          index: index,
          series: series,
          color: model.colors[(series * model.values[series].count + index) % model.colors.count]
        )
        barNode.opacity = opacity
        platformNode.addChildNode(barNode)

        let positionX = previousX + barWidth + barWidth * (index == 0 ? 0 : 0.5)
        barNode.position = SCNVector3(
          x: positionX + shiftX, y: 0.5 * value, z: positionZ + shiftZ
        )

        if series == 0 {
          addLabel(forIndex: index, atXPosition: positionX + shiftX, withMaxHeight: barWidth)
        }
        
        previousX = positionX
      }
      
      addLabel(forSeries: series, atZPosition: positionZ + shiftZ, withMaxHeight: barLength)
      previousZ = positionZ
    }
    self.platformNode = platformNode
    addChildNode(platformNode)
  }

  public func highlight(barNode: Bar?, highlight: Bool) {
    guard let platformNode else { return }
    for node in platformNode.childNodes {
      if let barNode, let node = node as? Bar, barNode != node, let box = node.geometry as? SCNBox {
        let startingHeight: Double = highlight ? node.height : 0
        let finalHeight: Double = highlight ? 0 : node.height

        let boxKey = "height"
        let nodeKey = "position.y"
        box.addAnimation(
          makeAnimation(keyPath: boxKey, from: startingHeight, to: finalHeight),
          forKey: boxKey
        )
        node.addAnimation(
          makeAnimation(
            keyPath: nodeKey,
            from: 0.5 * startingHeight,
            to: 0.5 * finalHeight
          ),
          forKey: nodeKey
        )
      }
    }

    highlightedBarNode = barNode
  }

  public func unhighlight() {
    highlight(barNode: highlightedBarNode, highlight: false)
    highlightedBarNode = nil
  }

  private func getTotalGap(for number: Int) -> Float {
    return Array(0..<number).reduce(0, { partialResult, _ -> Float in
      partialResult + 0.5
    })
  }

  private func addLabel(forSeries series: Int, atZPosition zPosition: Float, withMaxHeight maxHeight: Float) {
    if series < model.seriesLabels.count {
      let seriesLabelNode = Label(text: model.seriesLabels[series], backgroundColor: .clear)

      let unscaledLabelWidth = seriesLabelNode.boundingBox.max.x - seriesLabelNode.boundingBox.min.x
      let desiredLabelWidth = model.size.x * 0.3
      let unscaledLabelHeight = seriesLabelNode.boundingBox.max.y - seriesLabelNode.boundingBox.min.y
      let labelScale = min(desiredLabelWidth / unscaledLabelWidth, maxHeight / unscaledLabelHeight)
      seriesLabelNode.scale = SCNVector3(labelScale, labelScale, labelScale)

      let zShift = 0.5 * maxHeight - (maxHeight - labelScale * unscaledLabelHeight)
      seriesLabelNode.position = SCNVector3(
        x: -0.8 * model.size.x,
        y: 0.0,
        z: zPosition + zShift
      )
      seriesLabelNode.eulerAngles = SCNVector3(-0.5 * Float.pi, 0.0, 0.0)

      addChildNode(seriesLabelNode)
    }
  }

  private func addLabel(forIndex index: Int, atXPosition xPosition: Float, withMaxHeight maxHeight: Float) {
    if index < model.indexLabels.count {
      let indexLabelNode = Label(text: model.indexLabels[index], backgroundColor: .clear)

      let unscaledLabelWidth = indexLabelNode.boundingBox.max.x - indexLabelNode.boundingBox.min.x
      let desiredLabelWidth = model.size.z * 0.3
      let unscaledLabelHeight = indexLabelNode.boundingBox.max.y - indexLabelNode.boundingBox.min.y
      let labelScale = min(desiredLabelWidth / unscaledLabelWidth, maxHeight / unscaledLabelHeight)
      indexLabelNode.scale = SCNVector3(labelScale, labelScale, labelScale)

      let xShift = (maxHeight - labelScale * unscaledLabelHeight) - 0.5 * maxHeight
      indexLabelNode.position = SCNVector3(
        x: xPosition + xShift,
        y: 0.0,
        z: -0.8 * model.size.z
      )
      indexLabelNode.eulerAngles = SCNVector3(-0.5 * Float.pi, -0.5 * Float.pi, 0.0)

      addChildNode(indexLabelNode)
    }
  }
}


private func makeAnimation(keyPath: String, from: Double, to: Double) -> CABasicAnimation {
  let animation = CABasicAnimation(keyPath: keyPath)
  animation.fillMode = .forwards
  animation.isRemovedOnCompletion = false
  animation.fromValue = from
  animation.toValue = to
  animation.duration = 0.3
  return animation
}
