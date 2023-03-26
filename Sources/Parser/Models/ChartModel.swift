//
//  ChartModel.swift
//  ARDiagrams
//
//  Created by Gleb Burstein on 10.03.2023.
//

import UIKit

public enum ChartModel {
  case bar(BarChartModel)
  case pie(PieChartModel)
}

public struct PieChartModel {
  public let values: [Double]
  public let labels: [String]
  public let colors: [UIColor]

  public init(values: [Double], labels: [String], colors: [UIColor]) {
    self.values = values
    self.labels = labels
    self.colors = colors
  }
}

public struct BarChartModel {
  public let values: [[Double]]
  public let indexLabels: [String]
  public let seriesLabels: [String]
  public let colors: [UIColor]

  public init(
    values: [[Double]],
    indexLabels: [String],
    seriesLabels: [String],
    colors: [UIColor]
  ) {
    self.values = values
    self.indexLabels = indexLabels
    self.seriesLabels = seriesLabels
    self.colors = colors
  }
}
