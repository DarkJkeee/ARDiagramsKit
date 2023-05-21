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
    opacity = model.opacity
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

    let totalGapForSeries: Float
      = Array(0..<model.values.count).reduce(0, { resSum, _ in resSum + 0.5 })
    let totalGapForIndexes: Float
      = Array(0..<maxNumberOfIndexes).reduce(0, { resSum, _ in resSum + 0.5 })

    let platformNode = Platform(
      width: CGFloat(model.size.x),
      length: CGFloat(model.size.z)
    )

    let barWidth = model.size.x / (Float(maxNumberOfIndexes) + totalGapForIndexes)
    let maxBarHeight = model.size.y / Float(maxValue - minValue)
    let barLength = model.size.z / (Float(model.values.count) + totalGapForSeries)

    let shiftX = -(model.size.x / 2)
    let shiftZ = -(model.size.z / 2)

    var previousZ: Float = 0.0
    for series in 0..<model.values.count {
      let positionZ = previousZ + barLength + barLength * (series == 0 ? 0 : 0.5)
      var previousX: Float = 0.0
      
      for index in 0..<model.values[series].count {
        let value = Float(model.values[series][index]) * maxBarHeight
        let position = previousX + barWidth + barWidth * (index == 0 ? 0 : 0.5)
        if series == 0, index < model.indexLabels.count {
          let (indexLabelNode, scaledLabelHeight) = makeAxesLabel(
            text: model.indexLabels[index],
            width: model.size.z * 0.3,
            height: barWidth
          )
          indexLabelNode.position = SCNVector3(
            x: position + shiftX + (barWidth - scaledLabelHeight) - 0.5 * barWidth,
            y: 0.0,
            z: -0.8 * model.size.z
          )
          indexLabelNode.eulerAngles = SCNVector3(-0.5 * Float.pi, -0.5 * Float.pi, 0.0)
          addChildNode(indexLabelNode)
        }

        let barNode = Bar(
          width: CGFloat(barWidth),
          height: CGFloat(value),
          length: CGFloat(barLength),
          index: index,
          series: series,
          color: model.colors[(series * model.values[series].count + index) % model.colors.count]
        )
        platformNode.addChildNode(barNode)

        barNode.position = SCNVector3(
          x: position + shiftX, y: 0.5 * value, z: positionZ + shiftZ
        )
        
        previousX = position
      }

      if series < model.seriesLabels.count {
        let (seriesLabelNode, scaledLabelHeight) = makeAxesLabel(
          text: model.seriesLabels[series],
          width: model.size.x * 0.3,
          height: barLength
        )
        seriesLabelNode.position = SCNVector3(
          x: -0.8 * model.size.x,
          y: 0.0,
          z: positionZ + shiftZ + 0.5 * barLength - (barLength - scaledLabelHeight)
        )
        seriesLabelNode.eulerAngles = SCNVector3(-0.5 * Float.pi, 0.0, 0.0)
        addChildNode(seriesLabelNode)
      }

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
}

private func makeAxesLabel(text: String, width: Float, height: Float) -> (Label, Float) {
  let label = Label(text: text)

  let unscaledLabelWidth = label.boundingBox.max.x - label.boundingBox.min.x
  let unscaledLabelHeight = label.boundingBox.max.y - label.boundingBox.min.y
  let labelScale = min(width / unscaledLabelWidth, height / unscaledLabelHeight)
  label.scale = SCNVector3(labelScale, labelScale, labelScale)

  return (label, labelScale * unscaledLabelHeight)
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
