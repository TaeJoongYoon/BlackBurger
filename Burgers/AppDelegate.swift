//
//  AppDelegate.swift
//  Burgers
//
//  Created by Tae joong Yoon on 25/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import UIKit

import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  // MARK: Properties
  
  var dependency: AppDependency!
  
  // MARK: UI
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    self.dependency = self.dependency ?? CompositionRoot.resolve()
    self.dependency.configureSDKs(application, launchOptions)
    self.dependency.configureAppearance()
    self.window = self.dependency.window
    
    return true
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    let handled: Bool = FBSDKApplicationDelegate.sharedInstance()
      .application(
        app,
        open: url,
        sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
        annotation: options[UIApplication.OpenURLOptionsKey.annotation]
    )
    
    // Add any custom logic here.
    return handled
  }

  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    
    let handled = FBSDKApplicationDelegate.sharedInstance()?.application(
      application,
      open: url,
      sourceApplication: sourceApplication,
      annotation: annotation
    )
    
    return handled!
  }

}
