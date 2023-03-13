//
//  ChartModel.swift
//  ARDiagrams
//
//  Created by Gleb Burstein on 10.03.2023.
//

import UIKit

enum ChartModel {
  case bar(BarChartModel)
  case pie(PieChartModel)
}

struct PieChartModel {
  let values: [Double]
  let colors: [UIColor]
}

struct BarChartModel {
  let values: [[Double]]
  let indexLabels: [String]
  let seriesLabels: [String]
  let colors: [UIColor]
}
