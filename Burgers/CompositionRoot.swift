//
//  CompositionRoot.swift
//  BlackBurger
//
//  Created by Tae joong Yoon on 17/05/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import Photos
import UIKit

import Crashlytics
import Fabric
import FBSDKCoreKit
import Firebase
import Kingfisher
import NMapsMap
import SnapKit
import Then
import Toaster

/*
 *  Reference From Suyeol Jeon (devxoul)
 *  Configure App Dependency with DI
 */

struct AppDependency {
  let window: UIWindow
  let configureSDKs: (UIApplication, [UIApplication.LaunchOptionsKey: Any]?) -> Void
  let configureAppearance: () -> Void
}

final class CompositionRoot {
  /// Builds a dependency graph and returns an entry view controller.
  static func resolve() -> AppDependency {
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.backgroundColor = .white
    window.makeKeyAndVisible()

    var presentLoginScreen: (() -> Void)!
    var presentMainScreen: (() -> Void)!
    var presentPostDetailScreen: ((Post) -> PostDetailViewController)!

    presentPostDetailScreen = { post in
      return PostDetailViewController(
        viewModel: PostDetailViewModel(),
        post: post
      )
    }
    
    presentLoginScreen = {
      let loginViewController = LoginViewController(
        viewModel: LoginViewModel(),
        presentSignUpScreen: {
          let signUpViewController = SignUpViewController(
            viewModel: SignUpViewModel(),
            presentMainScreen: presentMainScreen
          )
          
          return signUpViewController
      },
        presentMainScreen: presentMainScreen
      )
      
      window.setRootViewController(
        loginViewController,
        options: UIWindow.TransitionOptions(
          direction: .toTop,
          style: .easeInOut
        )
      )
    }
    
    presentMainScreen = {
      let suggestedViewController = SuggestedViewController(
        viewModel: SuggestedViewModel(),
        contentTabView: ContentTabViewController(
          contentViewControllers: [
            RecentViewController(
              viewModel: RecentViewModel(),
              presentPostDetailScreen: presentPostDetailScreen
            ),
            PopularViewController(
              viewModel: PopularViewModel(),
              presentPostDetailScreen: presentPostDetailScreen
            )
          ]
        ),
        presentPostScreen: { photos in
          return PostViewController(
            viewModel: PostViewModel(),
            photos: photos
          )
        }
      )
      let mapViewController = MapViewController(
        viewModel: MapViewModel(),
        presentRestaurantScreen: { restaurant in
          return RestaurantViewController(
            viewModel: RestaurantViewModel(),
            presentPostDetailScreen: presentPostDetailScreen,
            restaurant: restaurant
          )
        }
      )
      let userViewController = UserViewController(
        viewModel: UserViewModel(),
        presentPostListScreen: { isMyList in
          return PostListViewController(
            viewModel: PostListViewModel(),
            presentPostDetailScreen: presentPostDetailScreen,
            isMyList: isMyList
          )
        },
        presentTermsScreen: { isTerms in
          return TermsViewController(isTerms: isTerms)
        },
        presentLoginScreen: presentLoginScreen
      )
      
      let mainTabViewController = MainTabViewController(
        suggestedView: suggestedViewController,
        mapView: mapViewController,
        userView: userViewController
      )
      
      window.setRootViewController(
        mainTabViewController,
        options: UIWindow.TransitionOptions(
          direction: .toTop,
          style: .easeInOut
        )
      )
    }
    
    let splashViewController = SplashViewController(
      viewModel: SplashViewModel(),
      presentLoginScreen: presentLoginScreen,
      presentMainScreen: presentMainScreen
    )
    window.rootViewController = splashViewController

    return AppDependency(
      window: window,
      configureSDKs: self.configureSDKs,
      configureAppearance: self.configureAppearance
    )
  }

  static func configureSDKs(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) {
    // Firebase config
    FirebaseApp.configure()
    
    // Crashlytics config
    Fabric.with([Crashlytics.self])
    
    // Facebook config
    FBSDKApplicationDelegate.sharedInstance()?
      .application(application,didFinishLaunchingWithOptions: launchOptions)
    
    // NaverMaps config
    NMFAuthManager.shared().clientId = PrivateKey.naverAPIKeyID
  }

  static func configureAppearance() {
    UITabBar.appearance().backgroundColor = .white
    UITabBar.appearance().shadowImage = UIImage()
    UITabBar.appearance().backgroundImage = UIImage()
    UITabBar.appearance().clipsToBounds = true
    UITabBar.appearance().tintColor = .tintColor
    
    UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.mainColor]
    UINavigationBar.appearance().clipsToBounds = true
    UINavigationBar.appearance().tintColor = .tintColor

    ToastView.appearance().font = UIFont.preferredFont(forTextStyle: .subheadline)
  }

}
