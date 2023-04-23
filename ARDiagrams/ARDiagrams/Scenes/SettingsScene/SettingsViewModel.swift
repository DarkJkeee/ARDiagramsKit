//
//  SettingsViewModel.swift
//  ARDiagrams
//
//  Created by Gleb Burstein on 06.04.2023.
//

import SwiftUI

import Charts

final class SettingsViewModel: ObservableObject {
  enum ColorPalette {
    static let flat: [Color] = [
      .init(red: 38 / 255, green: 55 / 255, blue: 85 / 255),
      .init(red: 94 / 255, green: 90 / 255, blue: 91 / 255),
      .init(red: 224 / 255, green: 208 / 255, blue: 182 / 255),
      .init(red: 169 / 255, green: 151 / 255, blue: 111 / 255),
      .init(red: 53 / 255, green: 57 / 255, blue: 69 / 255)
    ]

    static let vintage: [Color] = [
      .init(red: 217 / 255, green: 131 / 255, blue: 150 / 255),
      .init(red: 116 / 255, green: 89 / 255, blue: 116 / 255),
      .init(red: 153 / 255, green: 150 / 255, blue: 165 / 255),
      .init(red: 242 / 255, green: 215 / 255, blue: 198 / 255),
      .init(red: 224 / 255, green: 187 / 255, blue: 182 / 255)
    ]

    static let navy: [Color] = [
      .init(red: 120 / 255, green: 166 / 255, blue: 164 / 255),
      .init(red: 95 / 255, green: 94 / 255, blue: 88 / 255),
      .init(red: 216 / 255, green: 223 / 255, blue: 203 / 255),
      .init(red: 109 / 255, green: 125 / 255, blue: 123 / 255),
      .init(red: 73 / 255, green: 166 / 255, blue: 166 / 255)
    ]
  }

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
