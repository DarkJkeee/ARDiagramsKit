//
//  Platform.swift
//  
//
//  Created by Gleb Burstein on 23.04.2023.
//

import SceneKit

final class Platform: SCNNode {
  init(width: CGFloat, length: CGFloat) {
    let platformBox = SCNBox(
      width: width,
      height: 0.001,
      length: length,
      chamferRadius: 0
    )
    let platformMaterial = SCNMaterial()
    platformMaterial.diffuse.contents = UIColor.gray
    platformBox.materials = [platformMaterial]
    super.init()
    geometry = platformBox
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
