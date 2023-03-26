//
//  File.swift
//  
//
//  Created by Vladislav Shchukin on 25.03.2023.
//

import Foundation
import ZIPFoundation

protocol UnzipperProtocol {
  func unzip(zipUrl: URL, saveTo: URL)
}

class Unzipper: UnzipperProtocol {
  func unzip(zipUrl: URL, saveTo: URL) {

    guard zipUrl.startAccessingSecurityScopedResource() else { return }

    let fileManager = FileManager()
    do {
      try fileManager.unzipItem(at: zipUrl, to: saveTo)
    } catch {
      print(error.localizedDescription)
    }
    zipUrl.stopAccessingSecurityScopedResource()
  }
}
