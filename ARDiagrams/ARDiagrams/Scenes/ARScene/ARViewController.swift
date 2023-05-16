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
import Models
import Parser
import SmartHitTest

final class ARViewController: UIViewController {
  private struct SharedData: Codable {
    let sharedChart: Data?
    let sharedCollaborationData: Data
  }

  weak var coordinator: AppCoordinator?

  private lazy var sceneView = ARSCNView(frame: .zero)
  private lazy var focusSquare = FocusSquare()

  // Multi-user mode
  private var multipeerSession: MultipeerSession?
  private var sessionIDObservation: NSKeyValueObservation?

  private lazy var messageLabel = MessageLabel()

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
    button.isEnabled = false
    button.addTarget(self, action: #selector(handleSettingsButton), for: .touchUpInside)
    return button
  }()

  private var chart: Chart?
  private var chartModel: ChartModel? {
    didSet {
      chart?.chartModel = chartModel
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        self.addChartButton.isEnabled = self.chartModel != nil
        self.settingsButton.isEnabled = self.chartModel != nil
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    [sceneView, importButton, addChartButton, settingsButton, messageLabel]
      .forEach(view.addSubview)

    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    self.view.addGestureRecognizer(longPressRecognizer)
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
    sceneView.session.delegate = self
    configuration.isCollaborationEnabled = true
    configuration.planeDetection = [.horizontal, .vertical]
    sceneView.session.run(configuration)

    setupMultipeerSession()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    sceneView.session.pause()
  }

  private func addConstraints() {
    [messageLabel, importButton, addChartButton, settingsButton]
      .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

    NSLayoutConstraint.activate([
      messageLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      messageLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
      messageLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
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

  private func setupMultipeerSession() {
    // Use key-value observation to monitor your ARSession's identifier.
    sessionIDObservation = sceneView.session.observe(\.identifier, options: [.new]) { object, change in
      print("SessionID changed to: \(change.newValue!)")
      // Tell all other peers about your ARSession's changed ID, so
      // that they can keep track of which ARAnchors are yours.
      guard let multipeerSession = self.multipeerSession else { return }
      self.sendARSessionIDTo(peers: multipeerSession.connectedPeers)
    }

    // Start looking for other players via MultiPeerConnectivity.
    multipeerSession = MultipeerSession(
      serviceName: "ar-collab",
      receivedDataHandler: receivedData,
      peerJoinedHandler: peerJoined,
      peerLeftHandler: peerLeft,
      peerDiscoveredHandler: peerDiscovered
    )
  }

  private func extractChart(from model: ChartModel) -> Chart {
    switch model {
    case let .bar(model):
      return BarChart(model: model)
    case let .pie(model):
      return PieChart(model: model)
    }
  }

  private func drawChart(at position: SCNVector3) {
    guard let chart else { return }
    chart.draw()
    chart.position = position
    sceneView.scene.rootNode.addChildNode(chart)
  }

  private func importChart() {
    let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.spreadsheet])
    documentPicker.delegate = self
    documentPicker.allowsMultipleSelection = false
    documentPicker.modalPresentationStyle = .fullScreen
    present(documentPicker, animated: true, completion: nil)
  }

  private func openSettingsScreen() {
    guard let chartModel else { return }
    coordinator?.openSettings(model: chartModel, saveChanges: { [weak self] in
      self?.chartModel = $0
      self?.chart?.reset()
      self?.chart?.removeFromParentNode()
    })
  }

  @objc func handleLongPress(_ gestureRecognizer: UITapGestureRecognizer) {
    guard gestureRecognizer.state == .began else { return }
    
    let longPressLocation = gestureRecognizer.location(in: self.view)
    let selectedNode = self.sceneView.hitTest(longPressLocation, options: nil).first?.node
    if let barNode = selectedNode as? Bar, let barChart = chart as? BarChart {
      barChart.highlight(
        barNode: barNode,
        highlight: true
      )
    }
    
    let tapToUnhighlight = UITapGestureRecognizer(target: self, action: #selector(handleTapToUnhighlight))
    self.view.addGestureRecognizer(tapToUnhighlight)
  }

  @objc func handleTapToUnhighlight(_ gestureRecognizer: UITapGestureRecognizer) {
    (chart as? BarChart)?.unhighlight()
    self.view.removeGestureRecognizer(gestureRecognizer)
  }

  @objc private func handleTapChartButton(_ sender: UIButton) {
    guard let chartModel else { return }
    if multipeerSession?.connectedPeers.isEmpty == true {
      chart = extractChart(from: chartModel)
      drawChart(at: focusSquare.position)
    } else {
      let anchor = ARAnchor(name: "chart", transform: focusSquare.simdWorldTransform)
      sceneView.session.add(anchor: anchor)
    }
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
    self.chartModel = Parser().parseXLSX(from: url)
    controller.dismiss(animated: true)
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    controller.dismiss(animated: true)
  }
}

extension ARViewController: ARSessionDelegate {
  private func sendARSessionIDTo(peers: [PeerID]) {
    guard let multipeerSession = multipeerSession else { return }
    let idString = sceneView.session.identifier.uuidString
    let command = "SessionID:" + idString
    if let commandData = command.data(using: .utf8) {
      multipeerSession.sendToPeers(commandData, reliably: true, peers: peers)
    }
  }

  func receivedData(_ data: Data, from peer: PeerID) {
    guard let multipeerSession = multipeerSession else { return }

    if let sharedData = try? JSONDecoder().decode(SharedData.self, from: data) {
      if let sharedChart = sharedData.sharedChart,
         let decodedChartData = try? JSONDecoder().decode(ChartModel.self, from: sharedChart) {
        self.chart = extractChart(from: decodedChartData)
        chartModel = decodedChartData
      }
      if let decodedCollaborationData = try? NSKeyedUnarchiver.unarchivedObject(
        ofClass: ARSession.CollaborationData.self,
        from: sharedData.sharedCollaborationData
      ) {
        sceneView.session.update(with: decodedCollaborationData)
      }
    }

    let sessionIDCommandString = "SessionID:"
    if let commandString = String(data: data, encoding: .utf8), commandString.starts(with: sessionIDCommandString) {
      let newSessionID = String(commandString[commandString.index(
        commandString.startIndex,
        offsetBy: sessionIDCommandString.count
      )...])
      // If this peer was using a different session ID before, remove all its associated anchors.
      // This will remove the old participant anchor and its geometry from the scene.
      if let oldSessionID = multipeerSession.peerSessionIDs[peer] {
        removeAllAnchorsOriginatingFromARSessionWithID(oldSessionID)
      }

      multipeerSession.peerSessionIDs[peer] = newSessionID
    }
  }

  func peerDiscovered(_ peer: PeerID) -> Bool {
    guard let multipeerSession = multipeerSession else { return false }

    if multipeerSession.connectedPeers.count > 4 {
      // Do not accept more than four users in the experience.
      print("A fifth peer wants to join the experience.\nThis app is limited to four users.")
      return false
    } else {
      return true
    }
  }
  /// - Tag: PeerJoined
  func peerJoined(_ peer: PeerID) {
    print("""
          A peer wants to join the experience.
          Hold the phones next to each other.
          """)
    messageLabel.displayMessage("""
        A peer wants to join the experience.
        Hold the phones next to each other.
        """, duration: 6.0)
    // Provide your session ID to the new user so they can keep track of your anchors.
    sendARSessionIDTo(peers: [peer])
  }

  func peerLeft(_ peer: PeerID) {
    guard let multipeerSession = multipeerSession else { return }
    print("A peer has left the shared experience.")
    messageLabel.displayMessage("A peer has left the shared experience.")

    // Remove all ARAnchors associated with the peer that just left the experience.
    if let sessionID = multipeerSession.peerSessionIDs[peer] {
      removeAllAnchorsOriginatingFromARSessionWithID(sessionID)
      multipeerSession.peerSessionIDs.removeValue(forKey: peer)
    }
  }

  //  TODO
  private func removeAllAnchorsOriginatingFromARSessionWithID(_ identifier: String) {
    guard let frame = sceneView.session.currentFrame else { return }
    for anchor in frame.anchors {
      guard let anchorSessionID = anchor.sessionIdentifier else { continue }
      if anchorSessionID.uuidString == identifier {
        sceneView.session.remove(anchor: anchor)
      }
    }
  }

  func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
    guard let multipeerSession = multipeerSession else { return }
    if !multipeerSession.connectedPeers.isEmpty {
      guard let encodedCollaborationData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true),
            let encodedChartData = try? JSONEncoder().encode(chartModel),
            let sharedChart = try? JSONEncoder().encode(
              SharedData(
                sharedChart: encodedChartData,
                sharedCollaborationData: encodedCollaborationData
              )
            )
      else { fatalError("Unexpectedly failed to encode collaboration data.") }
      // Use reliable mode if the data is critical, and unreliable mode if the data is optional.
      let dataIsCritical = data.priority == .critical
      multipeerSession.sendToAllPeers(sharedChart, reliably: dataIsCritical)
    } else {
        print("Deferred sending collaboration to later because there are no peers.")
    }
  }

  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    if anchor.name == "chart" {
      drawChart(at: SCNVector3(
        anchor.transform.columns.3.x,
        anchor.transform.columns.3.y,
        anchor.transform.columns.3.z
      ))
    }
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
