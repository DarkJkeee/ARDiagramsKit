//
//  BarChartModel.swift
//  
//
//  Created by Gleb Burstein on 15.05.2023.
//

import UIKit

public struct BarChartModel: Codable, Equatable {
  private enum CodingKeys: String, CodingKey {
    case values, indexLabels, seriesLabels, colors, opacity, size
  }

  public var size: Size
  public var opacity: CGFloat
  public var values: [[Double]]
  public var colors: [UIColor]

  public let indexLabels: [String]
  public let seriesLabels: [String]

  public init(
    values: [[Double]],
    indexLabels: [String],
    seriesLabels: [String],
    colors: [UIColor],
    opacity: CGFloat,
    size: Size
  ) {
    self.values = values
    self.indexLabels = indexLabels
    self.seriesLabels = seriesLabels
    self.colors = colors
    self.opacity = opacity
    self.size = size
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    values = try container.decode([[Double]].self, forKey: .values)
    indexLabels = try container.decode([String].self, forKey: .indexLabels)
    seriesLabels = try container.decode([String].self, forKey: .seriesLabels)
    opacity = try container.decode(CGFloat.self, forKey: .opacity)
    size = try container.decode(Size.self, forKey: .size)
    colors = try container.decode([Color].self, forKey: .colors).map({ $0.uiColor })
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(values, forKey: .values)
    try container.encode(indexLabels, forKey: .indexLabels)
    try container.encode(seriesLabels, forKey: .seriesLabels)
    try container.encode(opacity, forKey: .opacity)
    try container.encode(size, forKey: .size)
    try container.encode(colors.map({ Color(uiColor: $0 )}), forKey: .colors)
  }
}
