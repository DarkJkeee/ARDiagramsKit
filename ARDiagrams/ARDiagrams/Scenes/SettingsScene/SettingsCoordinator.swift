//
//  SettingsCoordinator.swift
//  ARDiagrams
//
//  Created by Gleb Burstein on 16.05.2023.
//

import SwiftUI
import UIKit

import Models

final class SettingsCoordinator: Coordinator {
  private let saveChanges: SettingsViewModel.SaveHandler
  private let model: ChartModel

  var mainVC: UIViewController?

  init(model: ChartModel, saveChanges: @escaping SettingsViewModel.SaveHandler) {
    self.model = model
    self.saveChanges = saveChanges
  }

  func start() {
    mainVC = UIHostingController(
      rootView: SettingsView(
        viewModel: SettingsViewModel(model: model, saveChanges: saveChanges)
      )
    )
  }
}
