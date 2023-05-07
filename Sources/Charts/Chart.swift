//
//  Chart.swift
//  
//
//  Created by Gleb Burstein on 24.03.2023.
//

import SceneKit

import Models

public protocol Chart: SCNNode {
  var chartModel: ChartModel? { get set }
  func draw()
  func reset()
}

extension Chart {
  public func reset() {
    childNodes.forEach { $0.removeFromParentNode() }
  }
}
