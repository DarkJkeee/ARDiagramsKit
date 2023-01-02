//
//  AppCoordinator.swift
//  ARDiagrams
//
//  Created by Gleb Burstein on 06.03.2023.
//

import UIKit

final class AppCoordinator: Coordinator {
  private let window: UIWindow?

  init(window: UIWindow?) {
    self.window = window
  }

  func start() {
    guard let window = window else { return }
    let arVC = ARViewController()
    window.rootViewController = arVC
    window.makeKeyAndVisible()
  }
}
