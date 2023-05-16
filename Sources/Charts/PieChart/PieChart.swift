//
//  PieChart.swift
//  
//
//  Created by Gleb Burstein on 07.03.2023.
//

import SceneKit

import Models

public final class PieChart: SCNNode, Chart {
  public var chartModel: ChartModel? {
    didSet {
      if let model = chartModel?.pieChartModel {
        self.model = model
      }
    }
  }

  private var model: PieChartModel

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public init(model: PieChartModel) {
    self.model = model
    super.init()
  }

  public func draw() {
    opacity = model.opacity
    let coreNode = SCNNode()
    coreNode.simdPosition = SIMD3(x: 0, y: 0, z: 0)

    addChildNode(coreNode)

    let totalSum = model.values.reduce(0, +)
    let center = CGPoint(x: 0, y: 0)

    var startAngle = 0.0

    for i in 0..<model.values.count {
      let percent = model.values[i] / totalSum

      let endAngle = 360 * percent + startAngle

      let bezierPath = UIBezierPath()

      buildSource(startAngle, endAngle, center, CGFloat(model.radius), bezierPath)

      let shape = SCNShape(path: bezierPath, extrusionDepth: 0.02)

      if i == model.colors.count {
        let color: UIColor
        if i % 2 == 0 {
          color = model.colors[i % model.colors.count].darker(by: 10)
        } else {
          color = model.colors[i % model.colors.count].lighter(by: 10)
        }
        shape.firstMaterial?.diffuse.contents = color
        model.colors.append(color)
      } else {
        shape.firstMaterial?.diffuse.contents = model.colors[i]
      }

      let shapeNode = SCNNode(geometry: shape)

      coreNode.addChildNode(shapeNode)
      startAngle = endAngle
    }

    let legendNode = SCNNode()

    legendNode.position = SCNVector3(x: coreNode.position.x + 0.1, y: coreNode.position.y, z: coreNode.position.z)

    for i in 0..<model.values.count {
      let entryNode = SCNNode()

      let boxGeometry = SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0)
      boxGeometry.firstMaterial?.diffuse.contents = model.colors[i]
      let boxNode = SCNNode(geometry: boxGeometry)
      boxNode.position = SCNVector3(x: 0.02, y: 0, z: 0)

      let labelGeometry = SCNText(string: "\(model.values[i])    \(model.labels[i])", extrusionDepth: 0.01)
      labelGeometry.firstMaterial?.diffuse.contents = UIColor.black
      let labelNode = SCNNode(geometry: labelGeometry)
      labelNode.scale = SCNVector3(x: 0.001, y: 0.001, z: 0.001)
      labelNode.position = SCNVector3(x: 0.04, y: -0.005, z: 0)

      entryNode.addChildNode(boxNode)
      entryNode.addChildNode(labelNode)

      entryNode.position = SCNVector3(x: 0, y: -0.02 * Float(i), z: 0)

      legendNode.addChildNode(entryNode)
    }
    addChildNode(legendNode)

    eulerAngles = SCNVector3(-90 * .pi / 180.0, 0, 0)
  }
}

private func buildSource(
  _ startAngle: Double,
  _ endAngle: Double,
  _ center: CGPoint,
  _ radius: CGFloat,
  _ bezierPath: UIBezierPath
) {
  bezierPath.move(to: CGPoint(x: 0, y: 0))
  let steps = (endAngle - startAngle) / 20.0

  for angle in stride(from: startAngle, through: endAngle, by: steps) {
    let radians4 = Double(angle) * Double.pi / 180.0
    let x4 = Double(center.x) + Double(radius) * Double(cos(radians4))
    let y4 = Double(center.y) + Double(radius) * sin(radians4)
    bezierPath.addLine(to: CGPoint(x: x4, y: y4))
  }
}

extension UIColor {
  fileprivate func lighter(by percentage: CGFloat = 30.0) -> UIColor {
    return adjustBrightness(by: abs(percentage))
  }

  fileprivate func darker(by percentage: CGFloat = 30.0) -> UIColor {
    return adjustBrightness(by: -abs(percentage))
  }

  private func adjustBrightness(by percentage: CGFloat = 30.0) -> UIColor {
    var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
      if b < 1.0 {
        let newB: CGFloat = max(min(b + (percentage/100.0)*b, 1.0), 0.0)
        return UIColor(hue: h, saturation: s, brightness: newB, alpha: a)
      } else {
        let newS: CGFloat = min(max(s - (percentage/100.0)*s, 0.0), 1.0)
        return UIColor(hue: h, saturation: newS, brightness: b, alpha: a)
      }
    }
    return self
  }
}
