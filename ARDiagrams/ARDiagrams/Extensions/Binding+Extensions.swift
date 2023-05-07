//
//  Binding+Extensions.swift
//  ARDiagrams
//
//  Created by Gleb Burstein on 02.05.2023.
//

import SwiftUI

extension Binding {
  func optionalBinding<T>() -> Binding<T>? where T? == Value {
    if let wrappedValue = wrappedValue {
      return Binding<T>(
        get: { wrappedValue },
        set: { self.wrappedValue = $0 }
      )
    } else {
      return nil
    }
  }
}
