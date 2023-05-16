//
//  ChartLabel.swift
//
//
//  Created by Gleb Burstein on 07.03.2023.
//

import Foundation
import SceneKit

final class Label: SCNNode {
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(text: String) {
    super.init()

    let textNode = SCNText(string: text, extrusionDepth: 0.0)
    textNode.font = UIFont.systemFont(ofSize: 10.0)
    textNode.firstMaterial!.isDoubleSided = true
    textNode.firstMaterial!.diffuse.contents = UIColor.black

    geometry = textNode

    let backgroundWidth = CGFloat(1.05 * (textNode.boundingBox.max.x - textNode.boundingBox.min.x))
    let backgroundHeight = CGFloat(1.2 * (textNode.boundingBox.max.y - textNode.boundingBox.min.y))
    let backgroundPlane = SCNPlane(width: backgroundWidth, height: backgroundHeight)
    backgroundPlane.cornerRadius = 0.15 * min(backgroundPlane.width, backgroundPlane.height)
    backgroundPlane.firstMaterial?.diffuse.contents = UIColor.clear
    let backgroundNode = SCNNode(geometry: backgroundPlane)
    backgroundNode.position = SCNVector3(0.495 * backgroundWidth, 0.7 * backgroundHeight, -0.05)

    self.addChildNode(backgroundNode)
  }
}
