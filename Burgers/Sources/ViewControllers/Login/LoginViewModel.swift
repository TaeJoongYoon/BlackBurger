//
//  LoginViewModrl.swift
//  Burgers
//
//  Created by Tae joong Yoon on 06/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol LoginViewModelInputsType {
  var email: BehaviorRelay<String> { get }
  var password: BehaviorRelay<String> { get }
  var tappedSignUpButton: PublishSubject<Void> { get }
  var tappedDoneButton: PublishSubject<Void> { get }
  var tappedLoginButton: PublishSubject<Void> { get }
}

protocol LoginViewModelOutputsType {
  var isLoginEnabled: Driver<Bool> { get }
  var pushSignup: Driver<Void> { get }
  var isLogined: Driver<Bool> { get }
}

protocol LoginViewModelType: ViewModelType {
  var inputs: LoginViewModelInputsType { get }
  var outputs: LoginViewModelOutputsType { get }
}

final class LoginViewModel: LoginViewModelType, LoginViewModelInputsType, LoginViewModelOutputsType {
  
  var inputs: LoginViewModelInputsType { return self }
  var outputs: LoginViewModelOutputsType { return self }
  
  // MARK: Input
  
  let email = BehaviorRelay<String>(value: "")
  let password = BehaviorRelay<String>(value: "")
  let tappedSignUpButton = PublishSubject<Void>()
  let tappedDoneButton = PublishSubject<Void>()
  let tappedLoginButton = PublishSubject<Void>()
  
  // MARK: Output
  
  let isLoginEnabled: Driver<Bool>
  let pushSignup: Driver<Void>
  let isLogined: Driver<Bool>
  
  // MARK: - Initialize
  
  init() {
    
    let credential = Observable.combineLatest(email.asObservable(), password.asObservable())
    
    isLoginEnabled = Observable
      .combineLatest(email.asObservable(), password.asObservable()) { (email, password) in
        !email.isEmpty && !password.isEmpty
      }
      .asDriver(onErrorJustReturn: false)
    
    pushSignup = tappedSignUpButton
      .asDriver(onErrorJustReturn: ())
    
    isLogined = Observable<Void>
      .merge([tappedDoneButton, tappedLoginButton])
      .withLatestFrom(credential)
      .flatMapLatest{
        return AuthService.shared.login(email: $0.0, password: $0.1)
      }
      .asDriver(onErrorJustReturn: false)
    
  }
  
}
