//
//  ARViewController.swift
//  ARDiagrams
//
//  Created by Gleb Burstein on 06.03.2023.
//

import ARKit
import SceneKit
import UIKit

import Charts
import FocusNode
import Parser
import SmartHitTest

final class ARViewController: UIViewController {
  private lazy var sceneView = ARSCNView(frame: .zero)
  private lazy var focusSquare = FocusSquare()
  private lazy var importButton: UIButton = {
    let configuration = makeButtonConfiguration(title: "Import")

    let button = UIButton(configuration: configuration)
    button.addTarget(self, action: #selector(importChartButton), for: .touchUpInside)
    return button
  }()

  private lazy var addChartButton: UIButton = {
    let configuration = makeButtonConfiguration(title: "Chart!")

    let button = UIButton(configuration: configuration)
    button.isEnabled = false
    button.addTarget(self, action: #selector(handleTapChartButton), for: .touchUpInside)
    return button
  }()

  private var chart: Chart?

  private var chartModel: ChartModel? {
    didSet {
      addChartButton.isEnabled = chartModel != nil
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(sceneView)
    view.addSubview(importButton)
    view.addSubview(addChartButton)

    addConstraints()
    setupScene()
    addLightSource(ofType: .omni)
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
    [importButton, addChartButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    NSLayoutConstraint.activate([
      addChartButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      addChartButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      addChartButton.heightAnchor.constraint(equalToConstant: 90),
      addChartButton.widthAnchor.constraint(equalToConstant: 90),
      importButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      importButton.trailingAnchor.constraint(equalTo: addChartButton.leadingAnchor, constant: -20),
      importButton.widthAnchor.constraint(equalToConstant: 120),
      importButton.heightAnchor.constraint(equalToConstant: 60),
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

    focusSquare.viewDelegate = sceneView
    sceneView.scene.rootNode.addChildNode(focusSquare)
  }

  private func addLightSource(ofType type: SCNLight.LightType, at position: SCNVector3? = nil) {
    let light = SCNLight()
    light.color = UIColor.white
    light.type = type
    light.intensity = 1500

    let lightNode = SCNNode()
    lightNode.light = light
    if let lightPosition = position {
      lightNode.position = lightPosition
      self.sceneView.scene.rootNode.addChildNode(lightNode)
    } else {
      self.sceneView.pointOfView?.addChildNode(lightNode)
    }
  }

  private func drawChart(at position: SCNVector3) {
    switch chartModel {
    case let .bar(chart):
      let barChart = BarChart(
        values: chart.values,
        barColors: chart.colors,
        seriesLabels: chart.seriesLabels,
        indexLabels: chart.indexLabels,
        size: SCNVector3(x: 0.1, y: 0.1, z: 0.1)
      )
      self.chart = barChart
    case let .pie(chart):
      self.chart = PieChart(
        values: chart.values,
        labels: chart.labels,
        colors: chart.colors
      )
    case .none:
      return
    }
    if let chart {
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

  @objc private func handleTapChartButton(_ sender: UIButton) {
    self.drawChart(at: self.focusSquare.position)
  }

  @objc private func importChartButton(_ sender: UIButton) {
    self.importChart()
  }
}

extension ARViewController: ARSCNViewDelegate {
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    self.focusSquare.updateFocusNode()
  }
}

extension ARViewController: UIDocumentPickerDelegate {
  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    guard let url = urls.first else { return }

    let parser = Parser()

    chartModel = parser.parseXLSX(from: url)

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
