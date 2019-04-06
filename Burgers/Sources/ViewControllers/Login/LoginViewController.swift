//
//  LoginViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 06/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth
import RxCocoa
import RxSwift

final class LoginViewController: BaseViewController {
  
  // MARK: Constants
  
  struct Metric {
    static let logoFontSize = CGFloat(30)
    static let orFontSize = CGFloat(20)
    static let buttonRadius = CGFloat(5)
    static let height = 40
    static let leftRightOffset = 30
    static let topBottomOffset = 10
    static let buttonOffset = 20
    static let fbOffset = 60
  }
  
  
  // MARK: Properties
  
  var viewModel: LoginViewModelType!
  
  // MARK: UI
  
  let logo = UILabel(frame: .zero).then {
    $0.text = "BLACK BURGER"
    $0.textColor = .white
    $0.font = UIFont.systemFont(ofSize: Metric.logoFontSize)
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
  
  let orLabel = UILabel(frame: .zero).then {
    $0.text = "or".localized
    $0.textColor = .white
    $0.font = UIFont.systemFont(ofSize: Metric.orFontSize)
  }
  
  let loginButton = UIButton(type: .system).then {
    $0.setTitle("Log in".localized, for: .normal)
    $0.backgroundColor = .disabledColor
    $0.setTitleColor(.white, for: .normal)
    $0.layer.cornerRadius = Metric.buttonRadius
    $0.clipsToBounds = true
    $0.isEnabled = false
  }
  
  let fbloginButton = FBSDKLoginButton()

  // MARK: Setup UI
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .black
    
    let backBarButtton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    self.navigationItem.backBarButtonItem = backBarButtton
    
    self.view.addSubview(logo)
    self.view.addSubview(emailTextField)
    self.view.addSubview(passwordTextField)
    self.view.addSubview(signupButton)
    self.view.addSubview(loginButton)
    self.view.addSubview(orLabel)
    self.view.addSubview(fbloginButton)
    
    fbloginButton.readPermissions = ["email"]
    fbloginButton.delegate = self
  }
  
  // MARK: Setup Constraints
  
  override func setupConstraints() {
    
    self.logo.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.view.safeArea.top).offset(40)
    }
    
    self.emailTextField.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.logo.snp.bottom).offset(60)
      make.left.equalTo(self.view).offset(Metric.leftRightOffset)
      make.right.equalTo(self.view).offset(-Metric.leftRightOffset)
      make.height.equalTo(Metric.height)
    }
    
    self.passwordTextField.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.emailTextField.snp.bottom).offset(Metric.topBottomOffset)
      make.left.equalTo(self.view).offset(Metric.leftRightOffset)
      make.right.equalTo(self.view).offset(-Metric.leftRightOffset)
      make.height.equalTo(Metric.height)
    }
    
    self.signupButton.snp.makeConstraints { make in
      make.top.equalTo(self.passwordTextField.snp.bottom).offset(Metric.buttonOffset)
      make.right.equalTo(self.view).offset(-Metric.leftRightOffset)
    }
    
    self.loginButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.signupButton.snp.bottom).offset(Metric.buttonOffset)
      make.left.equalTo(self.view).offset(Metric.leftRightOffset)
      make.right.equalTo(self.view).offset(-Metric.leftRightOffset)
      make.height.equalTo(Metric.height)
    }
    
    self.orLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.loginButton.snp.bottom).offset(Metric.fbOffset)
    }
    
    self.fbloginButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.orLabel.snp.bottom).offset(Metric.fbOffset)
      make.left.equalTo(self.view).offset(Metric.leftRightOffset)
      make.right.equalTo(self.view).offset(-Metric.leftRightOffset)
    }
    
  }
  
  // MARK: - -> Rx Event Binding
  
  override func eventBinding() {
    
    self.emailTextField.rx.text
      .orEmpty
      .bind(to: viewModel.inputs.email)
      .disposed(by: self.disposeBag)
    
    self.passwordTextField.rx.text
      .orEmpty
      .bind(to: viewModel.inputs.password)
      .disposed(by: self.disposeBag)
    
    self.signupButton.rx.tap
      .bind(to: viewModel.inputs.tappedSignUpButton)
      .disposed(by: self.disposeBag)
    
    self.passwordTextField.rx.controlEvent(.editingDidEndOnExit)
      .bind(to: viewModel.inputs.tappedDoneButton)
      .disposed(by: self.disposeBag)
    
    self.loginButton.rx.tap
      .do(onNext: { [weak self] in
        self?.loginButton.setTitle("", for: .normal)
        self?.loginButton.loadingIndicator(show: true)
      })
      .bind(to: viewModel.inputs.tappedLoginButton)
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: - <- Rx UI Binding
  
  override func uiBinding() {
    
    self.emailTextField.rx.controlEvent(.editingDidEndOnExit)
      .subscribe(onNext: { [weak self] in
        self?.passwordTextField.becomeFirstResponder()
      })
      .disposed(by: self.disposeBag)
    
    self.passwordTextField.rx.controlEvent(.editingDidEndOnExit)
      .subscribe(onNext: { [weak self] in
        self?.passwordTextField.resignFirstResponder()
      })
      .disposed(by: self.disposeBag)
    
    viewModel.outputs.isLoginEnabled
      .drive(onNext: { [weak self] in
        self?.isLoginEnabled($0)
      })
      .disposed(by: self.disposeBag)
    
    viewModel.outputs.pushSignup
      .drive(onNext: { [weak self] in
        self?.pushSignup()
      })
      .disposed(by: self.disposeBag)
    
    viewModel.outputs.isLogined
      .drive(onNext: { [weak self] in
        self?.isLogined($0)
      })
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: Action Handler
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }
  
  private func isLoginEnabled(_ enable: Bool) {
    self.loginButton.isEnabled = enable
    self.loginButton.backgroundColor = enable ? .tintColor : .disabledColor
  }
  
  private func pushSignup() {
    let signUpViewController = appDelegate.container.resolve(SignUpViewController.self)!
    self.navigationController?.pushViewController(signUpViewController, animated: true)
  }
  
  private func isLogined(_ isLogined: Bool) {
    self.loginButton.setTitle("Log in".localized, for: .normal)
    self.loginButton.loadingIndicator(show: false)
    
    if isLogined {
      self.presentMainScreen()
    } else {
      self.showAlert()
    }
  }
  
  private func presentMainScreen() {
    let mainViewController = appDelegate.container.resolve(MainTabViewController.self)!
    
    UIApplication.shared.keyWindow?
      .setRootViewController(mainViewController,
                             options: UIWindow.TransitionOptions.init(
                              direction: .toBottom,
                              style: .easeInOut))
  }
  
  private func showAlert() {
    let alert = UIAlertController(title: "BLACK BURGER".localized,
                                  message: "The account is invalid, please check it".localized,
                                  preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "OK".localized, style: .default, handler: nil)
    alert.addAction(defaultAction)
    
    self.present(alert, animated: true, completion: nil)
  }
  
}


extension LoginViewController: FBSDKLoginButtonDelegate {
  func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    log.verbose("Facebook loginButton Did LogOut")
  }
  
  func loginButton(_ loginButton: FBSDKLoginButton!,
                   didCompleteWith result: FBSDKLoginManagerLoginResult!,
                   error: Error!) {
    if let error = error {
      log.error(error.localizedDescription)
      return
    }
    
    if let token = FBSDKAccessToken.current()?.tokenString {
      setToken(token: token)
      let credential = FacebookAuthProvider.credential(withAccessToken: token)
      
      Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
        if let error = error {
          log.error(error.localizedDescription)
          return
        }
        self.presentMainScreen()
      }
    }
  }
}
