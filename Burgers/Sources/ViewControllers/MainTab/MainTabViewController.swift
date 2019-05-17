//
//  ViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 25/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import UIKit

final class MainTabViewController: UITabBarController {
  
  // MARK: Initialize
  
  init(
    suggestedView: SuggestedViewController,
    mapView: MapViewController,
    userView: UserViewController
    ) {
    super.init(nibName: nil, bundle: nil)
    self.viewControllers = [suggestedView, mapView, userView]
      .map {
        let nav = UINavigationController(rootViewController: $0)
        return nav
    }
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
