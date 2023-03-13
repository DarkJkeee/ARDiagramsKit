//
//  ChartLabel.swift
//
//
//  Created by Gleb Burstein on 07.03.2023.
//

import Foundation
import SceneKit

class ARChartLabel: SCNNode {
  enum LabelType {
    case index
    case series
  }

  let type: LabelType
  let id: Int

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(text: SCNText, type: LabelType, id: Int, backgroundColor: UIColor) {
    self.type = type
    self.id = id

    super.init()
    self.geometry = text

    let backgroundWidth = CGFloat(1.05 * (text.boundingBox.max.x - text.boundingBox.min.x))
    let backgroundHeight = CGFloat(1.2 * (text.boundingBox.max.y - text.boundingBox.min.y))
    let backgroundPlane = SCNPlane(width: backgroundWidth, height: backgroundHeight)
    backgroundPlane.cornerRadius = 0.15 * min(backgroundPlane.width, backgroundPlane.height)
    backgroundPlane.firstMaterial?.diffuse.contents = backgroundColor
    let backgroundNode = SCNNode(geometry: backgroundPlane)
    backgroundNode.position = SCNVector3(0.495 * backgroundWidth, 0.7 * backgroundHeight, -0.05)

    self.addChildNode(backgroundNode)
  }
}
