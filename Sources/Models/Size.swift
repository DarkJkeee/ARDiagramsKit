//
//  Size.swift
//  
//
//  Created by Gleb Burstein on 15.05.2023.
//

import Foundation

public struct Size: Codable, Equatable {
  public var x: Float
  public var y: Float
  public var z: Float

  public init(x: Float = 0.1, y: Float = 0.1, z: Float = 0.1) {
    self.x = x
    self.y = y
    self.z = z
  }
}
