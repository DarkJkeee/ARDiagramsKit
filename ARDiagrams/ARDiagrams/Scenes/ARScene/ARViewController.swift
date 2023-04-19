//
//  ARViewController.swift
//  ARDiagrams
//
//  Created by Gleb Burstein on 06.03.2023.
//

import ARKit
import SceneKit
import SwiftUI
import UIKit

import Charts
import FocusNode
import Parser
import SmartHitTest

final class ARViewController: UIViewController {
  private lazy var sceneView = ARSCNView(frame: .zero)
  private lazy var focusSquare = FocusSquare()
  private var settingsVC: UIViewController?

  private lazy var importButton: UIButton = {
    let configuration = makeButtonConfiguration(title: "Import")

    let button = UIButton(configuration: configuration)
    button.addTarget(self, action: #selector(handleImportChartButton), for: .touchUpInside)
    return button
  }()

  private lazy var addChartButton: UIButton = {
    let configuration = makeButtonConfiguration(title: "Chart!")

    let button = UIButton(configuration: configuration)
    button.isEnabled = false
    button.addTarget(self, action: #selector(handleTapChartButton), for: .touchUpInside)
    return button
  }()

  private lazy var settingsButton: UIButton = {
    let configuration = makeButtonConfiguration(title: "Settings")

    let button = UIButton(configuration: configuration)
    button.addTarget(self, action: #selector(handleSettingsButton), for: .touchUpInside)
    return button
  }()

  private var chartSettings: ChartSettings = .init()

  private var chart: Chart? {
    didSet {
      addChartButton.isEnabled = chart != nil
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    [sceneView, importButton, addChartButton, settingsButton].forEach(view.addSubview)

    addConstraints()
    setupScene()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    sceneView.frame = view.bounds
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = [.horizontal, .vertical]
    sceneView.session.run(configuration)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    sceneView.session.pause()
  }

  private func addConstraints() {
    [importButton, addChartButton, settingsButton]
      .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

    NSLayoutConstraint.activate([
      importButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
      importButton.trailingAnchor.constraint(equalTo: addChartButton.leadingAnchor, constant: -20),
      importButton.widthAnchor.constraint(equalToConstant: 120),
      importButton.heightAnchor.constraint(equalToConstant: 60),
      addChartButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      addChartButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      addChartButton.heightAnchor.constraint(equalToConstant: 90),
      addChartButton.widthAnchor.constraint(equalToConstant: 90),
      settingsButton.leadingAnchor.constraint(equalTo: addChartButton.trailingAnchor, constant: 20),
      settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
      settingsButton.widthAnchor.constraint(equalToConstant: 120),
      settingsButton.heightAnchor.constraint(equalToConstant: 60),
    ])
  }

  private func setupScene() {
    sceneView.delegate = self
    sceneView.antialiasingMode = .multisampling4X
    sceneView.automaticallyUpdatesLighting = false
    sceneView.contentScaleFactor = 1.0
    sceneView.preferredFramesPerSecond = 60

    if let camera = sceneView.pointOfView?.camera {
      camera.wantsHDR = true
      camera.wantsExposureAdaptation = true
      camera.exposureOffset = -1
      camera.minimumExposure = -1
    }

    let light = SCNLight()
    light.color = UIColor.white
    light.type = .omni
    light.intensity = 1500

    let lightNode = SCNNode()
    lightNode.light = light
    sceneView.pointOfView?.addChildNode(lightNode)

    focusSquare.viewDelegate = sceneView
    sceneView.scene.rootNode.addChildNode(focusSquare)
  }

  private func setupChart(with model: ChartModel) {
    switch model {
    case let .bar(chart):
      self.chart = BarChart(
        values: chart.values,
        barColors: chart.colors,
        seriesLabels: chart.seriesLabels,
        indexLabels: chart.indexLabels
      )
    case let .pie(chart):
      self.chart = PieChart(
        values: chart.values,
        labels: chart.labels,
        colors: chart.colors
      )
    }
  }

  private func drawChart(at position: SCNVector3) {
    if let chart {
      chart.reset()
      chart.removeFromParentNode()
      chart.settings = chartSettings
      chart.draw()
      chart.position = position
      sceneView.scene.rootNode.addChildNode(chart)
    }
  }

  private func importChart() {
    let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.spreadsheet])
    documentPicker.delegate = self
    documentPicker.allowsMultipleSelection = false
    documentPicker.modalPresentationStyle = .fullScreen
    present(documentPicker, animated: true, completion: nil)
  }

  private func openSettingsScreen() {
    settingsVC = UIHostingController(rootView: SettingsView(
      viewModel: SettingsViewModel(
        chartSettings: chartSettings,
        saveChanges: { [weak self] in
          self?.chartSettings = $0
          self?.settingsVC?.dismiss(animated: true)
        }
      )
    ))
    if let settingsVC {
      present(settingsVC, animated: true, completion: nil)
    }
  }

  @objc private func handleTapChartButton(_ sender: UIButton) {
    drawChart(at: focusSquare.position)
  }

  @objc private func handleImportChartButton(_ sender: UIButton) {
    importChart()
  }

  @objc private func handleSettingsButton(_ sender: UIButton) {
    openSettingsScreen()
  }
}

extension ARViewController: ARSCNViewDelegate {
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    focusSquare.updateFocusNode()
  }
}

extension ARViewController: UIDocumentPickerDelegate {
  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    guard let url = urls.first else { return }
    let parser = Parser()

    let chartModel = parser.parseXLSX(from: url)
    if let chartModel {
      setupChart(with: chartModel)
    }
    controller.dismiss(animated: true)
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    controller.dismiss(animated: true)
  }
}

extension ARSCNView: ARSmartHitTest {}

private func makeButtonConfiguration(title: String) -> UIButton.Configuration {
  var configuration = UIButton.Configuration.filled()
  configuration.title = title
  configuration.baseBackgroundColor = UIColor.systemPink
  configuration.contentInsets = NSDirectionalEdgeInsets(
    top: 10,
    leading: 20,
    bottom: 10,
    trailing: 20
  )
  configuration.cornerStyle = .capsule
  return configuration
}
