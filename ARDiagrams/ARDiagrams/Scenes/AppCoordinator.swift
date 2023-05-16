//
//  AppCoordinator.swift
//  ARDiagrams
//
//  Created by Gleb Burstein on 06.03.2023.
//

import UIKit
import SwiftUI

import Models

final class AppCoordinator: Coordinator {
  private let window: UIWindow?
  private var mainVC: UIViewController?

  private var settingsCoordinator: SettingsCoordinator?

  init(window: UIWindow?) {
    self.window = window
  }

  func start() {
    guard let window = window else { return }
    let arViewController = ARViewController()
    arViewController.coordinator = self
    mainVC = arViewController
    window.rootViewController = mainVC
    window.makeKeyAndVisible()
  }

  func openSettings(model: ChartModel, saveChanges: @escaping SettingsViewModel.SaveHandler) {
    settingsCoordinator = SettingsCoordinator(
      model: model,
      saveChanges: { [weak self] in
        saveChanges($0)
        self?.settingsCoordinator?.mainVC?.dismiss(animated: true)
      }
    )
    settingsCoordinator?.start()
    if let presentedVC = settingsCoordinator?.mainVC, let mainVC {
      mainVC.present(presentedVC, animated: true, completion: nil)
    }
  }
}
