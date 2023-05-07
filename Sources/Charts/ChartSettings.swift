//
//  ChartSettings.swift
//
//
//  Created by Gleb Burstein on 06.04.2023.
//

import UIKit

public struct ChartSettings {
  public struct Size {
    public var x: Float
    public var y: Float
    public var z: Float

    public init(x: Float = 0.1, y: Float = 0.1, z: Float = 0.1) {
      self.x = x
      self.y = y
      self.z = z
    }
  }

  public var size: Size
  public var opacity: CGFloat
  public var colors: [UIColor]?

  public init(size: Size = .init(), opacity: CGFloat = 1, colors: [UIColor]? = nil) {
    self.size = size
    self.opacity = opacity
    self.colors = colors
  }
}
