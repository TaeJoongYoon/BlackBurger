//
//  UINavigationController+Pop.swift
//  Burgers
//
//  Created by Tae joong Yoon on 27/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import UIKit

extension UINavigationController {
  func popViewController(animated: Bool, completion: @escaping () -> Void) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    self.popViewController(animated: true)
    CATransaction.commit()
  }
  
  func pushViewController(
    viewController: UIViewController,
    animated: Bool,
    completion: @escaping ()-> Void
    ) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    self.pushViewController(viewController, animated: animated)
    CATransaction.commit()
  }
}
