//
//  ChartModel.swift
//  ARDiagrams
//
//  Created by Gleb Burstein on 10.03.2023.
//

import Foundation

public enum ChartModel: Codable, Equatable {
  case bar(BarChartModel)
  case pie(PieChartModel)
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
