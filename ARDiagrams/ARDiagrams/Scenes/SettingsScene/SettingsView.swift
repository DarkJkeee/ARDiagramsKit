//
//  SettingsViewController.swift
//  ARDiagrams
//
//  Created by Gleb Burstein on 06.03.2023.
//

import SwiftUI

import Models

struct SettingsView: View {
  @ObservedObject private var viewModel: SettingsViewModel

  init(viewModel: SettingsViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    NavigationView {
      VStack {
        if let model = $viewModel.barModel.optionalBinding() {
          makeBarChartSettingsView(model: model)
        } else if let model = $viewModel.pieModel.optionalBinding() {
          makePieChartSettingsView(model: model)
        }
        Button("Save") {
          viewModel.save()
        }
        .foregroundColor(.white)
        .padding()
        .background(Color.pink)
        .clipShape(Capsule())
      }.padding()
    }
  }

  private func makeBarChartSettingsView(model: Binding<BarChartModel>) -> some View {
    return Form {
      Section("Data") {
        NavigationLink {
          EditBarChartDataView(model: model)
        } label: {
          Text("Edit data")
        }
      }
      Section("Size") {
        HStack {
          Text("X:")
          TextField("X", value: model.size.x, format: .number)
        }
        HStack {
          Text("Y:")
          TextField("Y", value: model.size.y, format: .number)
        }
        HStack {
          Text("Z:")
          TextField("Z", value: model.size.z, format: .number)
        }
      }
      Section("Opacity") {
        HStack {
          Text(String(format: "%.2f", viewModel.barModel?.opacity ?? 0))
          Slider(value: model.opacity, in: 0...1)
        }
      }
      Section("Colors") {
        HStack {
          ForEach(viewModel.colorPalette, id: \.self) { colors in
            AngularGradient(gradient: Gradient(colors: colors), center: .center, startAngle: .zero, endAngle: .degrees(360))
              .frame(width: 50, height: 50)
              .if(viewModel.barModel?.colors == colors.map { UIColor($0) }) {
                $0.border(Color.gray, width: 3)
              }
              .cornerRadius(6)
              .contentShape(Circle())
              .onTapGesture {
                viewModel.barModel?.colors = colors.map { UIColor($0) }
              }
          }
        }
      }
    }
  }

  private func makePieChartSettingsView(model: Binding<PieChartModel>) -> some View {
    return Form {
      Section("Data") {
        NavigationLink {
          EditPieChartDataView(model: model)
        } label: {
          Text("Edit data")
        }
      }
      Section("Radius") {
        HStack {
          Text("Value:")
          TextField("", value: model.radius, format: .number)
        }
      }
      Section("Opacity") {
        HStack {
          Text(String(format: "%.2f", viewModel.pieModel?.opacity ?? 0))
          Slider(value: model.opacity, in: 0...1)
        }
      }
      Section("Colors") {
        HStack {
          ForEach(viewModel.colorPalette, id: \.self) { colors in
            AngularGradient(
              gradient: Gradient(colors: colors),
              center: .center,
              startAngle: .zero,
              endAngle: .degrees(360)
            )
            .frame(width: 50, height: 50)
            .if(viewModel.pieModel?.colors == colors.map { UIColor($0) }) {
              $0.border(Color.gray, width: 3)
            }
            .cornerRadius(6)
            .contentShape(Circle())
            .onTapGesture {
              viewModel.pieModel?.colors = colors.map { UIColor($0) }
            }
          }
        }
      }
    }
  }
}

private struct EditBarChartDataView: View {
  let model: Binding<BarChartModel>

  var body: some View {
    Group {
      ScrollView([.horizontal, .vertical]) {
        LazyVStack(alignment: .leading, spacing: 1, pinnedViews: [.sectionHeaders, .sectionFooters]) {
          Section(header: headerView(columns: model.wrappedValue.indexLabels)) {
            ForEach(0..<model.values.count, id: \.self) { rowIndex in
              let values = model.values[rowIndex]
              LazyHStack(spacing: 1) {
                Text(model.wrappedValue.seriesLabels[rowIndex])
                  .frame(width: 50)
                  .padding()
                  .background(Color.gray)

                ForEach(0..<values.count, id: \.self) { columnIndex in
                  TextField("", value: model.values[rowIndex][columnIndex], format: .number)
                    .frame(width: 70)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                }
              }
            }
          }
        }
      }
      .edgesIgnoringSafeArea(.top)
    }
    .padding(.top, 1)
  }

  private func headerView(columns: [String]) -> some View {
    LazyHStack(spacing: 1) {
      ForEach(columns, id: \.self) { column in
        Text(column)
          .frame(width: 70)
          .padding()
          .background(Color.gray)
      }
      Spacer()
    }.padding(.leading, 83)
  }
}

private struct EditPieChartDataView: View {
  let model: Binding<PieChartModel>

  var body: some View {
    Group {
      ScrollView([.horizontal, .vertical]) {
        LazyVStack(alignment: .leading, spacing: 1, pinnedViews: [.sectionHeaders, .sectionFooters]) {
          Section(header: headerView(columns: model.wrappedValue.labels)) {
            LazyHStack(spacing: 1) {
              ForEach(0..<model.values.count, id: \.self) { index in
                TextField("", value: model.values[index], format: .number)
                  .frame(width: 70)
                  .padding()
                  .background(Color.gray.opacity(0.2))
              }
            }
          }
        }
      }
      .edgesIgnoringSafeArea(.top)
    }
    .padding(.top, 1)
  }

  private func headerView(columns: [String]) -> some View {
    LazyHStack(spacing: 1) {
      ForEach(columns, id: \.self) { column in
        Text(column)
          .frame(width: 70)
          .padding()
          .background(Color.gray)
      }
      Spacer()
    }
  }
}
