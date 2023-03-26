//
//  File.swift
//  
//
//  Created by Vladislav Shchukin on 25.03.2023.
//

import Foundation
import UIKit
import SwiftyXMLParser

protocol XMLParserProtocol: AnyObject {
  func parseChart(from: Data) -> ChartModel?
}

class XMLParser: XMLParserProtocol {

  func parseChart(from chartData: Data) -> ChartModel? {
    let xml = XML.parse(chartData)
    switch getTypeOf(chart: xml) {
    case .pie:
      print("pie")
      return parserPie(from: xml)
    case .bar:
      print("bar")
      return parseBar(from: xml)
    case .unknown:
      print("nil")
      return nil
    }
  }

  private func getTypeOf(chart xml: XML.Accessor) -> ChartType {
    
    guard let nameElement = xml["c:chartSpace"]["c:chart"]["c:plotArea"].element else { return .unknown }

    if nameElement.childElements.contains(where: { $0.name == "c:pieChart" }) {
      return .pie
    }
    if nameElement.childElements.contains(where: { $0.name == "c:bar3DChart" }) {
      return .bar
    }

    return .unknown
  }

  func parseBar(from xml: XML.Accessor) -> ChartModel? {
    let rootIndElement = xml["c:chartSpace"]["c:chart"]["c:plotArea"]["c:bar3DChart"]["c:ser"][0]["c:cat"]["c:numRef"]["c:numCache"]["c:pt"]

    var values = [[Double]]()
    var seriesLabels = [String]()
    let indexLabels = rootIndElement.compactMap { ind in
      ind["c:v"].text
    }

    let rootValElement = xml["c:chartSpace"]["c:chart"]["c:plotArea"]["c:bar3DChart"]["c:ser"]
    for element in rootValElement {
      let valElement = element["c:val"]["c:numRef"]["c:numCache"]["c:pt"]
      let row = valElement
        .compactMap { val in
          val["c:v"].text
        }
        .compactMap {Double($0)}
      values.append(row)

      let seriesElement = element["c:tx"]["c:strRef"]["c:strCache"]["c:pt"]["c:v"].text
      seriesLabels.append(seriesElement ?? "")
    }

    var col = [UIColor]()
    for _ in 0 ..< values.count {
      col.append(UIColor(
        red: .random(in: 0...1),
        green: .random(in: 0...1),
        blue: .random(in: 0...1), alpha: 1)
      )
    }

    return ChartModel.bar(BarChartModel(values: values, indexLabels: indexLabels, seriesLabels: seriesLabels, colors: col))
  }

  func parserPie(from xml: XML.Accessor) -> ChartModel? {
    let catElement = xml["c:chartSpace"]["c:chart"]["c:plotArea"]["c:pieChart"]["c:ser"]["c:cat"]["c:strRef"]["c:strCache"]["c:pt"]

    let cat = catElement.compactMap { val in
      val["c:v"].text
    }

    let valElement = xml["c:chartSpace"]["c:chart"]["c:plotArea"]["c:pieChart"]["c:ser"]["c:val"]["c:numRef"]["c:numCache"]["c:pt"]

    let val = valElement
      .compactMap { val in
        val["c:v"].text
      }
      .compactMap {Double($0)}

    var col = [UIColor]()
    for _ in 0 ..< val.count {
      col.append(UIColor(
        red: .random(in: 0...1),
        green: .random(in: 0...1),
        blue: .random(in: 0...1), alpha: 1)
      )
    }
    return ChartModel.pie(
      PieChartModel(
        values: val,
        labels: cat,
        colors: col
      )
    )
  }
}

private enum ChartType {
  case bar
  case pie
  case unknown
}
