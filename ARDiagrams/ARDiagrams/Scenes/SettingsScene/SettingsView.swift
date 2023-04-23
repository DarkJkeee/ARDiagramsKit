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

extension View {
  @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}
