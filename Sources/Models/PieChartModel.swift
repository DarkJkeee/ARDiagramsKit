//
//  PieChartModel.swift
//  
//
//  Created by Gleb Burstein on 15.05.2023.
//

import UIKit

public struct PieChartModel: Codable, Equatable {
  private enum CodingKeys: String, CodingKey { case values, labels, colors, opacity, radius }

  public var radius: Float
  public var opacity: CGFloat
  public var values: [Double]
  public var colors: [UIColor]

  public let labels: [String]

  public init(values: [Double], labels: [String], colors: [UIColor], opacity: CGFloat, radius: Float) {
    self.values = values
    self.labels = labels
    self.colors = colors
    self.opacity = opacity
    self.radius = radius
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    values = try container.decode([Double].self, forKey: .values)
    labels = try container.decode([String].self, forKey: .labels)
    opacity = try container.decode(CGFloat.self, forKey: .opacity)
    radius = try container.decode(Float.self, forKey: .radius)
    colors = try container.decode([Color].self, forKey: .colors).map({ $0.uiColor })
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(values, forKey: .values)
    try container.encode(labels, forKey: .labels)
    try container.encode(opacity, forKey: .opacity)
    try container.encode(radius, forKey: .radius)
    try container.encode(colors.map({ Color(uiColor: $0 )}), forKey: .colors)
  }
}
