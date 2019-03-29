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
import Toaster

final class SplashViewController: BaseViewController, ViewType {
  
  // MARK: Constant
  
  struct Constant {
    static let duration = 0.5
  }
  
  struct Metric {
    static let logoFontSize = CGFloat(30)
  }
  
  // MARK: Properties
  
  var viewModel: SplashViewModelType!
  
  // MARK: UI
  
  let logoLabel = UILabel(frame: .zero).then {
    $0.text = "BURGERS"
    $0.textColor = .black
    $0.font = UIFont.systemFont(ofSize: Metric.logoFontSize)
  }
  
  // MARK: Setup UI
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.view.addSubview(logoLabel)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    Toast(text: "Enjoy your Hamburger :)".localized, duration: Delay.short).show()
  }
  
  // MARK: Setup Constraints
  
  override func setupConstraints() {
    self.logoLabel.snp.makeConstraints { make in
      make.center.equalTo(self.view)
    }
  }
  
  // MARK: - -> Rx Event Binding
  
  func setupEventBinding() {
    
    self.rx.viewDidAppear
      .delay(Constant.duration, scheduler: MainScheduler.instance)
      .bind(to: viewModel.checkIfAuthenticated)
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: - <- Rx UI Binding
  
  func setupUIBinding() {
    
    viewModel.isAuthenticated
      .drive(onNext: { [weak self] in
        $0 ? self?.presentMainScreen() : self?.presentLoginScreen()
      })
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: Action Handler
  
  private func presentLoginScreen() {
    let loginViewModel = LoginViewModel()
    let loginViewController = LoginViewController.create(with: loginViewModel)
    let navigationController = UINavigationController(rootViewController: loginViewController)
    navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController.navigationBar.clipsToBounds = true
    navigationController.navigationBar.tintColor = .tintColor
    
    UIApplication.shared.keyWindow?
      .setRootViewController(navigationController,
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
