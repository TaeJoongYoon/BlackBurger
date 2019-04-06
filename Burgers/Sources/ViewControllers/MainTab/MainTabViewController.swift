//
//  ViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 25/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import UIKit

final class MainTabViewController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    UIApplication.shared.keyWindow?.rootViewController = self
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // Hide Tabbar Line
    self.tabBar.shadowImage = UIImage()
    self.tabBar.backgroundImage = UIImage()
    self.tabBar.clipsToBounds = true
    self.tabBar.tintColor = .mainColor
    
    let suggestedView = appDelegate.container.resolve(SuggestedViewController.self)!
    let mapView = appDelegate.container.resolve(MapViewController.self)!
    let userView = appDelegate.container.resolve(UserViewController.self)!
    
    self.viewControllers = [suggestedView, mapView, userView]
      .map {
        let nav = UINavigationController(rootViewController: $0)
        nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
        nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mainColor]
        nav.navigationBar.clipsToBounds = true
        nav.navigationBar.tintColor = .tintColor
        
        return nav
    }
  }
}
