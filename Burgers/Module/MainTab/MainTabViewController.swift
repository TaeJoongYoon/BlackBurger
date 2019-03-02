//
//  ViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 25/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import UIKit

class MainTabViewController: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tabBar.shadowImage = UIImage()
    self.tabBar.backgroundImage = UIImage()
    self.tabBar.clipsToBounds = true
    self.tabBar.tintColor = .mainColor
    
    let suggestedViewModel = SuggestedViewModel()
    let suggestedView = SuggestedViewController.create(with: suggestedViewModel)
    
    let mapViewModel = MapViewModel()
    let mapView = MapViewController.create(with: mapViewModel)
    
    let userViewModel = UserViewModel()
    let userView = UserViewController.create(with: userViewModel)
    
    self.viewControllers = [suggestedView, mapView, userView]
      .map {
        let nav = UINavigationController(rootViewController: $0)
        nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
        nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mainColor]
        nav.navigationBar.clipsToBounds = true
        
        return nav
    }
  }
}
