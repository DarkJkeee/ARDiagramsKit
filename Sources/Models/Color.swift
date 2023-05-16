//
//  Color.swift
//  
//
//  Created by Gleb Burstein on 15.05.2023.
//

import UIKit

struct Color: Codable {
  var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0

  var uiColor: UIColor {
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }

  init(uiColor: UIColor) {
    uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
  }
}
