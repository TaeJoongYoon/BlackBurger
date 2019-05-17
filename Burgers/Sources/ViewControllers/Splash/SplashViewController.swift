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

final class SplashViewController: BaseViewController {
  
  // MARK: Constant
  
  fileprivate struct Constant {
    static let duration = 0.5
  }
  
  fileprivate struct Metric {
    static let logoFontSize = CGFloat(30)
  }
  
  // MARK: Properties
  
  fileprivate let viewModel: SplashViewModelType
  fileprivate let presentLoginScreen: () -> Void
  fileprivate let presentMainScreen: () -> Void
  
  // MARK: UI
  
  let logoLabel = UILabel(frame: .zero).then {
    $0.text = "BLACK BURGER"
    $0.textColor = .black
    $0.font = UIFont.systemFont(ofSize: Metric.logoFontSize)
  }
  
  // MARK: Initalize
  
  init(
    viewModel: SplashViewModelType,
    presentLoginScreen: @escaping () -> Void,
    presentMainScreen: @escaping () -> Void
    ) {
    self.viewModel = viewModel
    self.presentLoginScreen = presentLoginScreen
    self.presentMainScreen = presentMainScreen
    super.init()
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Setup UI
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    
    self.view.addSubview(logoLabel)
  }
  
  // MARK: Setup Constraints
  
  override func setupConstraints() {
    self.logoLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  // MARK: - -> Rx Event Binding
  
  override func bindingEvent() {
    
    self.rx.viewDidAppear
      .bind(to: viewModel.inputs.viewDidAppear)
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: - <- Rx UI Binding
  
  override func bindingUI() {
    
    viewModel.outputs.versionCheck
      .drive(onNext: { [weak self] in
        // After ViewDidAppear
        Toast(text: "Enjoy your Hamburger :)".localized, duration: Delay.short).show()
        self?.versionCheck($0, $1, $2)
      })
      .disposed(by: self.disposeBag)
    
    viewModel.outputs.isAuthenticated
      .drive(onNext: { [weak self] isAuthenticated in
        isAuthenticated ? self?.presentMainScreen() : self?.presentLoginScreen()
      })
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: Action Handler
  
  private func versionCheck(_ force: Bool, _ option: Bool, _ string: String) {
    let url = URL(string: string)!
    if force { // Force Update
      let alert = UIAlertController(
        title: "Update".localized,
        message: "forceUpdate".localized,
        preferredStyle: .alert
      )
      
      alert.addAction(UIAlertAction(
        title: "Update".localized,
        style: .default
      ) { _ in
        if UIApplication.shared.canOpenURL(url) {
          if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
          } else {
            UIApplication.shared.openURL(url)
          }
        }
      })
      self.navigationController?.present(alert, animated: true, completion: nil)
    } else {
      if option { // Optional Update
        let alert = UIAlertController(
          title: "Update".localized,
          message: "optionalUpdate".localized,
          preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
          title: "Update".localized,
          style: .default
        ) { _ in
          if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
              UIApplication.shared.open(url)
            } else {
              UIApplication.shared.openURL(url)
            }
          }
        })
        
        alert.addAction(UIAlertAction(
          title: "Later".localized,
          style: .default,
          handler: nil)
        )
        self.navigationController?.present(alert, animated: true, completion: nil)
      } else {  // Current Update
        self.viewModel.inputs.checkIfAuthenticated()
      }
    }
  }
  
//  private func presentLoginScreen() {
//    let loginViewController = appDelegate.container.resolve(LoginViewController.self)!
//    let navigationController = UINavigationController(rootViewController: loginViewController)
//    navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
//    navigationController.navigationBar.clipsToBounds = true
//    navigationController.navigationBar.tintColor = .tintColor
//
//    UIApplication.shared.keyWindow?
//      .setRootViewController(navigationController,
//                             options: UIWindow.TransitionOptions.init(
//                              direction: .toTop,
//                              style: .easeInOut))
//  }
//
//  private func presentMainScreen() {
//    let mainTabView = appDelegate.container.resolve(MainTabViewController.self)!
//
//    UIApplication.shared.keyWindow?
//      .setRootViewController(mainTabView,
//                             options: UIWindow.TransitionOptions.init(
//                              direction: .toTop,
//                              style: .easeInOut))
//  }
}
