//
//  UIButton+Indicator.swift
//  Burgers
//
//  Created by Tae joong Yoon on 09/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import UIKit

extension UIButton {
  func loadingIndicator(show: Bool) {
    let tag = 9876
    if show {
      let indicator = UIActivityIndicatorView()
      let buttonHeight = self.bounds.size.height
      let buttonWidth = self.bounds.size.width
      indicator.center = CGPoint(x: buttonWidth/2, y: buttonHeight/2)
      indicator.tag = tag
      
      self.addSubview(indicator)
      indicator.startAnimating()
    } else {
      if let indicator = self.viewWithTag(tag) as? UIActivityIndicatorView {
        indicator.stopAnimating()
        indicator.removeFromSuperview()
      }
    }
  }
}
