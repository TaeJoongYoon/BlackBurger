//
//  LoginViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 06/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

class LoginViewController: UIViewController, ViewType {
  
  // MARK: Constants
  
  struct Reusable {
    
  }
  
  struct Constant {
    
  }
  
  struct Metric {
    static let textfieldOffset = 30
    static let textfieldInset = 10
  }
  
  // MARK: Rx
  
  var disposeBag: DisposeBag!
  
  // MARK: Properties
  
  var viewModel: LoginViewModelType!
  
  // MARK: UI
  
  let emailTextField = UITextField(frame: .zero).then {
    $0.keyboardType = .emailAddress
    $0.returnKeyType = .next
    $0.placeholder = "email".localized
    $0.backgroundColor = .white
    $0.borderStyle = .roundedRect
    $0.adjustsFontSizeToFitWidth = true
  }
  
  let passwordTextField = UITextField(frame: .zero).then {
    $0.isSecureTextEntry = true
    $0.returnKeyType = .done
    $0.placeholder = "password".localized
    $0.backgroundColor = .white
    $0.borderStyle = .roundedRect
    $0.adjustsFontSizeToFitWidth = true
    $0.clearsOnBeginEditing = true
    $0.clearButtonMode = .whileEditing
  }
  
  
  
  let loginButton = UIButton(frame: .zero).then {
    $0.setTitle("Log in".localized, for: .normal)
    $0.backgroundColor = .tintColor
    $0.setTitleColor(.white, for: .normal)
    $0.layer.cornerRadius = 5
    $0.clipsToBounds = true
  }
  
  // MARK: Setup UI
  
  func setupUI() {
    
    self.view.backgroundColor = .black
    
    self.view.addSubview(emailTextField)
    self.view.addSubview(passwordTextField)
    self.view.addSubview(loginButton)
    
  }
  
  // MARK: Setup Constraints
  
  func setupConstraints() {
    
    self.emailTextField.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.view.safeArea.top).offset(100)
      make.left.equalTo(self.view).offset(Metric.textfieldOffset)
      make.right.equalTo(self.view).offset(-Metric.textfieldOffset)
    }
    
    self.passwordTextField.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.emailTextField.snp.bottom).offset(Metric.textfieldInset)
      make.left.equalTo(self.view).offset(Metric.textfieldOffset)
      make.right.equalTo(self.view).offset(-Metric.textfieldOffset)
    }
    
    self.loginButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.passwordTextField.snp.bottom).offset(Metric.textfieldInset)
      make.left.equalTo(self.view).offset(Metric.textfieldOffset)
      make.right.equalTo(self.view).offset(-Metric.textfieldOffset)
    }
    
  }
  
  // MARK: - -> Rx Event Binding
  
  func setupEventBinding() {
    
  }
  
  // MARK: - <- Rx UI Binding
  
  func setupUIBinding() {
    
  }
  
}
