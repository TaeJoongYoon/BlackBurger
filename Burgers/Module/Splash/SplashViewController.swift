//
//  SplashViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 06/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

class SplashViewController: UIViewController, ViewType {
  
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
  
  // MARK: Setup UI
  
  func setupUI() {
    self.view.backgroundColor = .white
  }
  
  // MARK: Setup Constraints
  
  func setupConstraints() {
    
  }
  
  // MARK: - -> Rx Event Binding
  
  func setupEventBinding() {
    
    rx.viewDidAppear
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
    
    UIApplication.shared.keyWindow?
      .setRootViewController(loginViewController,
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
