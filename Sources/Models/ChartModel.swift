//
//  ChartModel.swift
//  ARDiagrams
//
//  Created by Gleb Burstein on 10.03.2023.
//

import UIKit

public enum ChartModel: Codable, Equatable {
  case bar(BarChartModel)
  case pie(PieChartModel)
}

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

fileprivate struct Color : Codable {
  var red : CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0

  var uiColor : UIColor {
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }

  init(uiColor : UIColor) {
    uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
  }
}

extension ChartModel {
  public var barChartModel: BarChartModel? {
    switch self {
    case let .bar(model): return model
    case .pie: return nil
    }
  }

  public var pieChartModel: PieChartModel? {
    switch self {
    case let .pie(model): return model
    case .bar: return nil
    }
  }
}
