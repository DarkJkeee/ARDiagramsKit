//
//  Bar.swift
//  
//
//  Created by Gleb Burstein on 21.04.2023.
//

import SceneKit
import UIKit

public class Bar: SCNNode {
  public let height: Double
  public let series: Int
  public let index: Int

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public init(width: CGFloat, height: CGFloat, length: CGFloat, index: Int, series: Int, color: UIColor) {
    let barBox = SCNBox(
      width: width,
      height: height,
      length: length,
      chamferRadius: 0
    )
    self.height = height
    self.series = series
    self.index = index

    let material = SCNMaterial()
    material.diffuse.contents = color
    material.specular.contents = UIColor.white
    barBox.firstMaterial = material
    super.init()
    self.geometry = barBox
  }
}
