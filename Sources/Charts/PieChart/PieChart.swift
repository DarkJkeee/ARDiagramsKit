//
//  PieChart.swift
//  
//
//  Created by Gleb Burstein on 07.03.2023.
//

import SceneKit

public final class PieChart: SCNNode, Chart {
  private let values: [Double]
  private let labels: [String]
  private var colors: [UIColor]

  public var settings: ChartSettings = .init() {
    didSet {
      opacity = settings.opacity
      if let colors = settings.colors {
        self.colors = colors
      }
    }
  }

  public var type: ChartType {
    .pie
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public init(values: [Double], labels: [String], colors: [UIColor]) {
    self.values = values
    self.labels = labels
    self.colors = colors
    super.init()
  }

  public func draw() {
    let coreNode = SCNNode()
    coreNode.simdPosition = SIMD3(x: 0, y: 0, z: 0)

    addChildNode(coreNode)

    let totalSum = values.reduce(0, +)
    let center = CGPoint(x: 0, y: 0)
    let radius = 0.1

    var startAngle = 0.0

    for i in 0..<values.count {
      let percent = values[i] / totalSum

      let endAngle = 360 * percent + startAngle

      let bezierPath = UIBezierPath()

      buildSource(startAngle, endAngle, center, radius, bezierPath)

      // Add shapes
      let shape = SCNShape(path: bezierPath, extrusionDepth: 0.02)
      shape.firstMaterial?.diffuse.contents = colors[i % colors.count]

      let shapeNode = SCNNode(geometry: shape)

      coreNode.addChildNode(shapeNode)
      startAngle = endAngle
    }

    // Create the legend
    let legendNode = SCNNode()

    // Position the legend to the right of the pie chart
    legendNode.position = SCNVector3(x: coreNode.position.x + 0.1, y: coreNode.position.y, z: coreNode.position.z)

    // Loop through the slices array and create a legend entry for each slice
    for i in 0..<values.count {

      // Create a legend entry node
      let entryNode = SCNNode()

      // Create a colored box to represent the slice
      let boxGeometry = SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0)
      boxGeometry.firstMaterial?.diffuse.contents = colors[i % colors.count]
      let boxNode = SCNNode(geometry: boxGeometry)
      boxNode.position = SCNVector3(x: 0.02, y: 0, z: 0)

      // Create a text node to display the slice value
      let labelGeometry = SCNText(string: "\(values[i])    \(labels[i])", extrusionDepth: 0.01)
      labelGeometry.firstMaterial?.diffuse.contents = UIColor.black
      let labelNode = SCNNode(geometry: labelGeometry)
      labelNode.scale = SCNVector3(x: 0.001, y: 0.001, z: 0.001)
      labelNode.position = SCNVector3(x: 0.04, y: -0.005, z: 0)

      // Add the box and text nodes to the entry node
      entryNode.addChildNode(boxNode)
      entryNode.addChildNode(labelNode)

      // Position the entry node vertically
      entryNode.position = SCNVector3(x: 0, y: -0.02 * Float(i), z: 0)

      // Add the entry node to the legend node
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

private func buildExpansion(
  _ startAngle: Double,
  _ endAngle: Double,
  _ center: CGPoint,
  _ radius: CGFloat,
  _ bezierPath4: UIBezierPath
) {
  let r = startAngle - ((startAngle - endAngle) / 2)
  let radians4 = Double(r) * Double.pi / 180.0
  let osx = Double(center.x) + Double(radius / 4) * Double(cos(radians4))
  let osy = Double(center.y) + Double(radius / 4) * sin(radians4)

  bezierPath4.move(to: CGPoint(x: osx, y: osy))
  let steps = (endAngle - startAngle) / 20.0
  for angle in stride(from: startAngle, through: endAngle, by: steps) {
    let radians4 = Double(angle) * Double.pi / 180.0
    let x4 = Double(center.x) + Double(radius) * Double(cos(radians4))
    let y4 = Double(center.y) + Double(radius) * sin(radians4)
    bezierPath4.addLine(to: CGPoint(x: x4 + osx, y: y4 + osy))
  }
}
