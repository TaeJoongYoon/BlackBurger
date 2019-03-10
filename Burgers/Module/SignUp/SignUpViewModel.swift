//
//  SignUpViewModel.swift
//  Burgers
//
//  Created by Tae joong Yoon on 09/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import FirebaseAuth
import RxCocoa
import RxSwift

protocol SignUpViewModelType: ViewModelType {
  // Event
  var email: BehaviorRelay<String> { get }
  var password: BehaviorRelay<String> { get }
  var tappedDoneButton: PublishSubject<Void> { get }
  var tappedSignUpButton: PublishSubject<Void> { get }
  var info: PublishSubject<(String, String)> { get }
  
  // UI
  var isSignedUpEnabled: Driver<Bool> { get }
  var isSignedUp: Driver<Bool> { get }
}

struct SignUpViewModel: SignUpViewModelType {
  
  // Properties
  // MARK: -> Event
  let email = BehaviorRelay<String>(value: "")
  let password = BehaviorRelay<String>(value: "")
  let tappedDoneButton = PublishSubject<Void>()
  let tappedSignUpButton = PublishSubject<Void>()
  var info = PublishSubject<(String, String)>()
  
  // MARK: <- UI
  let isSignedUpEnabled: Driver<Bool>
  let isSignedUp: Driver<Bool>
  
  
  init() {
    
    let credential = Observable.combineLatest(email.asObservable(), password.asObservable())
    
    isSignedUpEnabled = Observable
      .combineLatest(email.asObservable(), password.asObservable()) { (email, password) in
        email.isValidEmail() && password.isValidPassword()
      }
      .asDriver(onErrorJustReturn: false)
    
    
    isSignedUp = Observable<Void>
      .merge([tappedDoneButton, tappedSignUpButton])
      .withLatestFrom(credential)
      .flatMapLatest{
        return AuthService.shared.signup(email: $0.0, password: $0.1)
      }
      .asDriver(onErrorJustReturn: false)
    
  }
  
}
