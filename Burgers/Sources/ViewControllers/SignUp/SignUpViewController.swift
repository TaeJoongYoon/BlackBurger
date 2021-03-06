//
//  SignUpViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 09/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

final class SignUpViewController: BaseViewController {
  
  // MARK: Constants
  
  fileprivate struct Metric {
    static let buttonRadius = CGFloat(5)
    static let height = 40
    static let textfieldOffset = 30
    static let textfieldInset = 10
  }
  
  // MARK: Properties
  
  fileprivate let viewModel: SignUpViewModelType
  fileprivate let presentMainScreen: () -> Void
  
  // MARK: UI
  
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
    $0.placeholder = "password (more than 8)".localized
    $0.backgroundColor = .textfieldColor
    $0.borderStyle = .roundedRect
    $0.adjustsFontSizeToFitWidth = true
    $0.clearsOnBeginEditing = true
    $0.clearButtonMode = .whileEditing
    $0.autocapitalizationType = .none
  }
  
  let signupButton = UIButton(type: .system).then {
    $0.setTitle("Sign Up".localized, for: .normal)
    $0.backgroundColor = .disabledColor
    $0.setTitleColor(.white, for: .normal)
    $0.layer.cornerRadius = Metric.buttonRadius
    $0.clipsToBounds = true
    $0.isEnabled = false
  }
  
  // MARK: Initalize
  
  init(
    viewModel: SignUpViewModelType,
    presentMainScreen: @escaping () -> Void
    ) {
    self.viewModel = viewModel
    self.presentMainScreen = presentMainScreen
    super.init()
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Setup UI
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .black
    
    self.view.addSubview(emailTextField)
    self.view.addSubview(passwordTextField)
    self.view.addSubview(signupButton)
  }
  
  // MARK: Setup Constraints
  
  override func setupConstraints() {
    
    self.emailTextField.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.view.safeArea.top).offset(100)
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
      make.centerX.equalToSuperview()
      make.top.equalTo(self.passwordTextField.snp.bottom).offset(Metric.textfieldOffset)
      make.left.equalTo(self.view).offset(Metric.textfieldOffset)
      make.right.equalTo(self.view).offset(-Metric.textfieldOffset)
      make.height.equalTo(Metric.height)
    }
    
  }
  
  // MARK: - -> Rx Event Binding
  
  override func bindingEvent() {
    
    self.emailTextField.rx.text
      .orEmpty
      .bind(to: viewModel.inputs.email)
      .disposed(by: self.disposeBag)
    
    self.passwordTextField.rx.text
      .orEmpty
      .bind(to: viewModel.inputs.password)
      .disposed(by: self.disposeBag)
    
    self.passwordTextField.rx.controlEvent(.editingDidEndOnExit)
      .bind(to: viewModel.inputs.tappedDoneButton)
      .disposed(by: self.disposeBag)
    
    self.signupButton.rx.tap
      .do(onNext: { [weak self] in
        self?.signupButton.setTitle("", for: .normal)
        self?.signupButton.loadingIndicator(show: true)
      })
      .bind(to: viewModel.inputs.tappedSignUpButton)
      .disposed(by: self.disposeBag)
    
    
  }
  
  // MARK: - <- Rx UI Binding
  
  override func bindingUI() {
    
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
    
    viewModel.outpus.isSignedUpEnabled
      .drive(onNext: { [weak self] in
        self?.isSignUpEnabled($0)
      })
      .disposed(by: self.disposeBag)
    
    viewModel.outpus.isSignedUp
      .drive(onNext: { [weak self] in
        self?.isSignedUp($0)
      })
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: Action Handler
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }
  
  private func isSignUpEnabled(_ enable: Bool) {
    self.signupButton.isEnabled = enable
    self.signupButton.backgroundColor = enable ? .tintColor : .disabledColor
  }
  
  private func isSignedUp(_ signed: Bool) {
    self.signupButton.setTitle("Sign Up".localized, for: .normal)
    self.signupButton.loadingIndicator(show: false)
    
    if signed {
      self.presentMainScreen()
    } else {
      self.showAlert()
    }
  }
  
  private func showAlert() {
    let alert = UIAlertController(
      title: "BLACK BURGER".localized,
      message: "The email address is already in use by another account".localized,
      preferredStyle: .alert
    )
    
    let defaultAction = UIAlertAction(title: "OK".localized, style: .default, handler: nil)
    alert.addAction(defaultAction)
    
    self.present(alert, animated: true, completion: nil)
  }
  
}
