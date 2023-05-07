//
//  File.swift
//  
//
//  Created by Vladislav Shchukin on 25.03.2023.
//

import Foundation

import Models

protocol ParserProtocol {
  func parseXLSX(from: URL) -> ChartModel?
}

public final class Parser: ParserProtocol {
  private var unzipper: UnzipperProtocol
  private var xmlParser: XMLParserProtocol

  public init() {
    self.unzipper = Unzipper()
    self.xmlParser = XMLParser()
  }

  public func parseXLSX(from: URL) -> ChartModel? {
    let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    unzipper.unzip(zipUrl: from, saveTo: tempDir)
    guard let chartData = getChartData(from: tempDir) else { return nil }
    return xmlParser.parseChart(from: chartData)
  }

  private func getChartData(from: URL) -> Data? {
    let fm = FileManager()
    let chartPath = from.path.appending("/xl/charts/chart1.xml")
    return fm.contents(atPath: chartPath)
  }

  private func getTypeOf(chart: Data) -> ChartType {
    return .pie
  }
}

private enum ChartType {
  case bar
  case pie
}
