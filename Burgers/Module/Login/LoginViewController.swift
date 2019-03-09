//
//  LoginViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 06/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxGesture
import RxSwift

class LoginViewController: UIViewController, ViewType {
  
  // MARK: Constants
  
  struct Reusable {
    
  }
  
  struct Constant {
    
  }
  
  struct Metric {
    static let height = 35
    static let textfieldOffset = 30
    static let textfieldInset = 10
    static let buttonInset = 20
  }
  
  // MARK: Rx
  
  var disposeBag: DisposeBag!
  
  // MARK: Properties
  
  var viewModel: LoginViewModelType!
  
  // MARK: UI
  
  let logo = UILabel(frame: .zero).then {
    $0.text = "BURGERS"
    $0.textColor = .white
    $0.font = UIFont.systemFont(ofSize: 30)
  }
  
  let emailTextField = UITextField(frame: .zero).then {
    $0.keyboardType = .emailAddress
    $0.returnKeyType = .next
    $0.placeholder = "email".localized
    $0.backgroundColor = .textfieldColor
    $0.borderStyle = .roundedRect
    $0.adjustsFontSizeToFitWidth = true
    $0.autocapitalizationType = .none
  }
  
  let passwordTextField = UITextField(frame: .zero).then {
    $0.isSecureTextEntry = true
    $0.returnKeyType = .done
    $0.placeholder = "password".localized
    $0.backgroundColor = .textfieldColor
    $0.borderStyle = .roundedRect
    $0.adjustsFontSizeToFitWidth = true
    $0.clearsOnBeginEditing = true
    $0.clearButtonMode = .whileEditing
    $0.autocapitalizationType = .none
  }
  
  let signupButton = UIButton(type: .system).then {
    $0.setTitle("Don't you have an account?".localized, for: .normal)
    $0.tintColor = .tintColor
  }
  
  let loginButton = UIButton(type: .system).then {
    $0.setTitle("Log in".localized, for: .normal)
    $0.backgroundColor = .disabledColor
    $0.setTitleColor(.white, for: .normal)
    $0.layer.cornerRadius = 5
    $0.clipsToBounds = true
    $0.isEnabled = false
  }
  
  // MARK: Setup UI
  
  func setupUI() {
    self.view.backgroundColor = .black
    
    self.view.addSubview(logo)
    self.view.addSubview(emailTextField)
    self.view.addSubview(passwordTextField)
    self.view.addSubview(signupButton)
    self.view.addSubview(loginButton)
    
  }
  
  // MARK: Setup Constraints
  
  func setupConstraints() {
    
    self.logo.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.view.safeArea.top).offset(40)
    }
    
    self.emailTextField.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.logo.snp.bottom).offset(60)
      make.left.equalTo(self.view).offset(Metric.textfieldOffset)
      make.right.equalTo(self.view).offset(-Metric.textfieldOffset)
      make.height.equalTo(Metric.height)
    }
    
    self.passwordTextField.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.emailTextField.snp.bottom).offset(Metric.textfieldInset)
      make.left.equalTo(self.view).offset(Metric.textfieldOffset)
      make.right.equalTo(self.view).offset(-Metric.textfieldOffset)
      make.height.equalTo(Metric.height)
    }
    
    self.signupButton.snp.makeConstraints { make in
      make.top.equalTo(self.passwordTextField.snp.bottom).offset(Metric.buttonInset)
      make.right.equalTo(self.view).offset(-Metric.textfieldOffset)
    }
    
    self.loginButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.signupButton.snp.bottom).offset(Metric.buttonInset)
      make.left.equalTo(self.view).offset(Metric.textfieldOffset)
      make.right.equalTo(self.view).offset(-Metric.textfieldOffset)
      make.height.equalTo(Metric.height)
    }
    
  }
  
  // MARK: - -> Rx Event Binding
  
  func setupEventBinding() {
    
    self.emailTextField.rx.text
      .orEmpty
      .bind(to: viewModel.email)
      .disposed(by: disposeBag)
    
    self.emailTextField.rx.controlEvent(.editingDidEndOnExit)
      .subscribe(onNext: { [weak self] in
        self?.passwordTextField.becomeFirstResponder()
      })
      .disposed(by: disposeBag)
    
    self.passwordTextField.rx.text
      .orEmpty
      .bind(to: viewModel.password)
      .disposed(by: disposeBag)
    
    self.passwordTextField.rx.controlEvent(.editingDidEndOnExit)
      .bind(to: viewModel.tappedDoneButton)
      .disposed(by: disposeBag)
    
    self.signupButton.rx.tap
      .bind(to: viewModel.tappedSignUpButton)
      .disposed(by: disposeBag)
    
    self.loginButton.rx.tap
      .do(onNext: { [weak self] in
        self?.loginButton.setTitle("", for: .normal)
        self?.loginButton.loadingIndicator(show: true)
      })
      .bind(to: viewModel.tappedLoginButton)
      .disposed(by: disposeBag)
    
  }
  
  // MARK: - <- Rx UI Binding
  
  func setupUIBinding() {
    
    viewModel.isLoginEnabled
      .drive(onNext: { [weak self] in
        self?.loginButton.isEnabled = $0
        self?.loginButton.backgroundColor = $0 ? .tintColor : .disabledColor
      })
      .disposed(by: disposeBag)
    
    viewModel.pushSignup
      .drive(onNext: { [weak self] in
        
        let signUpViewModel = SignUpViewModel()
        let signUpViewController = SignUpViewController.create(with: signUpViewModel)
        self?.navigationController?.pushViewController(signUpViewController, animated: true)
      })
      .disposed(by: disposeBag)
    
    viewModel.isLogined
      .drive(onNext: { [weak self] logined in
        self?.loginButton.setTitle("Log in".localized, for: .normal)
        self?.loginButton.loadingIndicator(show: false)
        
        if logined {
          self?.presentMainScreen()
        } else {
          self?.showAlert()
        }
      })
      .disposed(by: disposeBag)
    
  }
  
  // MARK: Action Handler
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }
  
  private func presentMainScreen() {
    let mainViewController = MainTabViewController()
    
    UIApplication.shared.keyWindow?
      .setRootViewController(mainViewController,
                             options: UIWindow.TransitionOptions.init(
                              direction: .toBottom,
                              style: .easeInOut))
  }
  
  private func showAlert() {
    let alert = UIAlertController(title: "Burgers",
                                  message: "The account is invalid, please check it".localized,
                                  preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(defaultAction)
    self.present(alert, animated: true, completion: nil)
  }
  
}

