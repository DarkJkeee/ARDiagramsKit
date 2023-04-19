//
//  SettingsViewController.swift
//  ARDiagrams
//
//  Created by Gleb Burstein on 06.03.2023.
//

import SwiftUI

import Charts

struct SettingsView: View {
  @ObservedObject private var viewModel: SettingsViewModel

  init(viewModel: SettingsViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    Form {
      VStack {
        Section("Size") {
          HStack {
            Text("X:")
            TextField("X", value: $viewModel.chartSettings.size.x, format: .number)
          }
          HStack {
            Text("Y:")
            TextField("Y", value: $viewModel.chartSettings.size.y, format: .number)
          }
          HStack {
            Text("Z:")
            TextField("Z", value: $viewModel.chartSettings.size.z, format: .number)
          }
        }
        Section("Opacity") {
          HStack {
            Text(String(format: "%.2f", viewModel.chartSettings.opacity))
            Slider(value: $viewModel.chartSettings.opacity, in: 0...1)
          }
        }
        Section("Colors") {
          HStack {
            ForEach(viewModel.colorPalette, id: \.self) { colors in
              AngularGradient(gradient: Gradient(colors: colors), center: .center, startAngle: .zero, endAngle: .degrees(360))
                .frame(width: 50, height: 50)
                .if(viewModel.chartSettings.colors == colors.map { UIColor($0) }) {
                  $0.border(Color.gray, width: 3)
                }
                .cornerRadius(6)
                .contentShape(Circle())
                .onTapGesture {
                  viewModel.chartSettings.colors = colors.map { UIColor($0) }
                }
            }
          }
        }
      }
    }

    Button("Save") {
      viewModel.save()
    }
    .foregroundColor(.white)
    .padding()
    .background(Color.pink)
    .clipShape(Capsule())
  }
}

enum ColorPalette {
  static let vintage: [Color] = [
    .init(red: 217 / 255, green: 131 / 255, blue: 150 / 255),
    .init(red: 116 / 255, green: 89 / 255, blue: 116 / 255),
    .init(red: 153 / 255, green: 150 / 255, blue: 165 / 255),
    .init(red: 242 / 255, green: 215 / 255, blue: 198 / 255),
    .init(red: 224 / 255, green: 187 / 255, blue: 182 / 255)
  ]

  static let flat: [Color] = [
    .init(red: 38 / 255, green: 55 / 255, blue: 85 / 255),
    .init(red: 94 / 255, green: 90 / 255, blue: 91 / 255),
    .init(red: 224 / 255, green: 208 / 255, blue: 182 / 255),
    .init(red: 169 / 255, green: 151 / 255, blue: 111 / 255),
    .init(red: 53 / 255, green: 57 / 255, blue: 69 / 255)
  ]

  static let navy: [Color] = [
    .init(red: 120 / 255, green: 166 / 255, blue: 164 / 255),
    .init(red: 95 / 255, green: 94 / 255, blue: 88 / 255),
    .init(red: 216 / 255, green: 223 / 255, blue: 203 / 255),
    .init(red: 109 / 255, green: 125 / 255, blue: 123 / 255),
    .init(red: 73 / 255, green: 166 / 255, blue: 166 / 255)
  ]
}

extension View {
  @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}
