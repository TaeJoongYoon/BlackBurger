//
//  SplashViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 06/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import FirebaseAuth
import RxCocoa
import RxSwift

final class SplashViewController: UIViewController, ViewType {
  
  // MARK: Constants
  
  struct Reusable {
    
  }
  
  struct Constant {
    
  }
  
  struct Metric {
    
  }
  
  // MARK: Rx
  
  var disposeBag: DisposeBag!
  
  // MARK: Properties
  
  var viewModel: SplashViewModelType!
  
  // MARK: UI
  
  let logo = UILabel(frame: .zero).then {
    $0.text = "BURGERS"
    $0.textColor = .black
    $0.font = UIFont.systemFont(ofSize: 30)
  }
  
  // MARK: Setup UI
  
  func setupUI() {
    self.view.backgroundColor = .white
    self.view.addSubview(logo)
    
    let firebaseAuth = Auth.auth()
    do {
      try firebaseAuth.signOut()
    } catch let signOutError as NSError {
      print ("Error signing out: %@", signOutError)
    }
  }
  
  // MARK: Setup Constraints
  
  func setupConstraints() {
    self.logo.snp.makeConstraints { make in
      make.center.equalTo(self.view)
    }
  }
  
  // MARK: - -> Rx Event Binding
  
  func setupEventBinding() {
    
    rx.viewDidAppear
      .delay(0.5, scheduler: MainScheduler.instance)
      .bind(to:viewModel.checkIfAuthenticated)
      .disposed(by: disposeBag)
    
  }
  
  // MARK: - <- Rx UI Binding
  
  func setupUIBinding() {
    
    viewModel.isAuthenticated
      .drive(onNext: { [weak self] in
        $0 ? self?.presentMainScreen() : self?.presentLoginScreen()
      })
      .disposed(by: disposeBag)
    
  }
  
  // MARK: Action Handler
  
  private func presentLoginScreen() {
    let loginViewModel = LoginViewModel()
    let loginViewController = LoginViewController.create(with: loginViewModel)
    let navi = UINavigationController(rootViewController: loginViewController)
    navi.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navi.navigationBar.clipsToBounds = true
    navi.navigationBar.tintColor = .tintColor
    
    UIApplication.shared.keyWindow?
      .setRootViewController(navi,
                             options: UIWindow.TransitionOptions.init(
                              direction: .toTop,
                              style: .easeInOut))
  }
  
  private func presentMainScreen() {
    let mainTabView = MainTabViewController()
    
    UIApplication.shared.keyWindow?
      .setRootViewController(mainTabView,
                             options: UIWindow.TransitionOptions.init(
                              direction: .toTop,
                              style: .easeInOut))
  }
}
