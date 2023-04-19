//
//  SettingsViewModel.swift
//  ARDiagrams
//
//  Created by Gleb Burstein on 06.04.2023.
//

import SwiftUI

import Charts

final class SettingsViewModel: ObservableObject {
  typealias SaveHandler = (ChartSettings) -> Void

  private let saveChanges: SaveHandler
  let colorPalette: [[Color]] = [ColorPalette.flat, ColorPalette.vintage, ColorPalette.navy]

  @Published var chartSettings: ChartSettings

  init(chartSettings: ChartSettings = .init(), saveChanges: @escaping SaveHandler) {
    self.chartSettings = chartSettings
    self.saveChanges = saveChanges
  }

  func save() {
    saveChanges(chartSettings)
  }
}
