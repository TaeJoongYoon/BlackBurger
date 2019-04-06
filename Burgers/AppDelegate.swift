//
//  AppDelegate.swift
//  Burgers
//
//  Created by Tae joong Yoon on 25/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import Photos
import UIKit

import Crashlytics
import Fabric
import FBSDKCoreKit
import Firebase
import NMapsMap
import Swinject
import Toaster

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  let container = Container()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    // Firebase config
    FirebaseApp.configure()
    
    // Crashlytics config
    Fabric.with([Crashlytics.self])
    
    // Facebook config
    FBSDKApplicationDelegate.sharedInstance()?
      .application(application,didFinishLaunchingWithOptions: launchOptions)
    
    // NaverMaps config
    NMFAuthManager.shared().clientId = "0hvz2ykiw6"

    window = UIWindow(frame: UIScreen.main.bounds)
    window?.makeKeyAndVisible()
    
    // Toaster config
    ToastView.appearance().bottomOffsetPortrait = (window?.safeAreaInsets.bottom)! + CGFloat(55)
    ToastView.appearance().font = UIFont.preferredFont(forTextStyle: .subheadline)
    
    // DI
    registerViewModel()
    registerViewController()
    
    self.window?.rootViewController = container.resolve(SplashViewController.self)
    
    return true
  }

  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    
    let handled = FBSDKApplicationDelegate.sharedInstance()?
      .application(application,
                   open: url,
                   sourceApplication: sourceApplication,
                   annotation: annotation)
    
    return handled!
  }

}

// MARK: DI

extension AppDelegate {
  func registerViewModel() {
    container.register(SplashViewModel.self) { r in SplashViewModel() }
    container.register(LoginViewModel.self) { r in LoginViewModel() }
    container.register(SignUpViewModel.self) { r in SignUpViewModel() }
    container.register(SuggestedViewModel.self) { r in SuggestedViewModel() }
    container.register(RecentViewModel.self) { r in RecentViewModel() }
    container.register(PopularViewModel.self) { r in PopularViewModel() }
    container.register(MapViewModel.self) { r in MapViewModel() }
    container.register(UserViewModel.self) { r in UserViewModel() }
    container.register(PostViewModel.self) { r in PostViewModel() }
    container.register(PostDetailViewModel.self) { r in PostDetailViewModel() }
    container.register(RestaurantViewModel.self) { r in RestaurantViewModel() }
    container.register(PostListViewModel.self) { r in PostListViewModel() }
  }
  
  func registerViewController() {
    container.register(SplashViewController.self) { r in
      let controller = SplashViewController()
      controller.viewModel = r.resolve(SplashViewModel.self)
      return controller
    }
    container.register(LoginViewController.self) { r in
      let controller = LoginViewController()
      controller.viewModel = r.resolve(LoginViewModel.self)
      return controller
    }
    container.register(SignUpViewController.self) { r in
      let controller = SignUpViewController()
      controller.viewModel = r.resolve(SignUpViewModel.self)
      return controller
    }
    container.register(RecentViewController.self) { r in
      let controller = RecentViewController()
      controller.viewModel = r.resolve(RecentViewModel.self)
      return controller
    }
    container.register(PopularViewController.self) { r in
      let controller = PopularViewController()
      controller.viewModel = r.resolve(PopularViewModel.self)
      return controller
    }
    container.register(SuggestedViewController.self) { r in
      let controller = SuggestedViewController()
      controller.viewModel = r.resolve(SuggestedViewModel.self)
      return controller
    }
    container.register(MapViewController.self) { r in
      let controller = MapViewController()
      controller.viewModel = r.resolve(MapViewModel.self)
      return controller
    }
    container.register(UserViewController.self) { r in
      let controller = UserViewController()
      controller.viewModel = r.resolve(UserViewModel.self)
      return controller
    }
    container.register(MainTabViewController.self) { r in
      let controller = MainTabViewController()
      return controller
    }
    container.register(PostViewController.self) { (r: Resolver, assets: [PHAsset]) in
      let controller = PostViewController()
      controller.viewModel = r.resolve(PostViewModel.self)
      controller.photos = assets
      return controller
    }
    container.register(PostDetailViewController.self) { (r: Resolver, post: Post) in
      let controller = PostDetailViewController()
      controller.viewModel = r.resolve(PostDetailViewModel.self)
      controller.post = post
      return controller
    }
    container.register(RestaurantViewController.self) { (r: Resolver, userInfo: [AnyHashable: Any]) in
      let controller = RestaurantViewController()
      controller.viewModel = r.resolve(RestaurantViewModel.self)
      controller.restaurant = userInfo
      return controller
    }
    container.register(PostListViewController.self) { r in
      let controller = PostListViewController()
      controller.viewModel = r.resolve(PostListViewModel.self)
      return controller
    }
    container.register(TermsViewController.self) { r in
      let controller = TermsViewController()
      return controller
    }
  }
}
