//
//  UIColor+BaseColor.swift
//  Burgers
//
//  Created by Tae joong Yoon on 02/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import UIKit

extension UIColor {
  static var mainColor: UIColor {
    return .black
  }
  
  static var tintColor: UIColor {
    return .orange
  }
  
  static var disabledColor: UIColor {
    return UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.5)
  }
  
  static var textfieldColor: UIColor {
    return UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
  }
}
