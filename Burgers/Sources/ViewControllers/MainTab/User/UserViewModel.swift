//
//  UserViewModel.swift
//  Burgers
//
//  Created by Tae joong Yoon on 25/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol UserViewModelType: ViewModelType {
  
  // Event
  var myPostButtonDidTapped: PublishSubject<Void> { get }
  var myLikeButtonDidTapped: PublishSubject<Void> { get }
  var changePasswordButtonDidTapped: PublishSubject<Void> { get }
  var requestPasswordChange: PublishSubject<String> { get }
  var termsButtonDidTapped: PublishSubject<Void> { get }
  var privacyButtonDidTapped: PublishSubject<Void> { get }
  var logoutButtonDidTapped: PublishSubject<Void> { get }
  var accountRemoveButtonDidTapped: PublishSubject<Void> { get }
  var requestRemove: PublishSubject<Void> { get }
  
  // UI
  var post: Driver<Void> { get }
  var like: Driver<Void> { get }
  var changePassword: Driver<Void> { get }
  var passwordChanged: Driver<Bool> { get }
  var terms: Driver<Void> { get }
  var privacy: Driver<Void> { get }
  var logout: Driver<Bool> { get }
  var accountRemove: Driver<Void> { get }
  var accountRemoved: Driver<Bool> { get }
  
}

struct UserViewModel: UserViewModelType {
  
  // MARK: Event
  
  let myPostButtonDidTapped = PublishSubject<Void>()
  let myLikeButtonDidTapped = PublishSubject<Void>()
  let changePasswordButtonDidTapped = PublishSubject<Void>()
  let requestPasswordChange = PublishSubject<String>()
  let termsButtonDidTapped = PublishSubject<Void>()
  let privacyButtonDidTapped = PublishSubject<Void>()
  let logoutButtonDidTapped = PublishSubject<Void>()
  let accountRemoveButtonDidTapped = PublishSubject<Void>()
  let requestRemove = PublishSubject<Void>()
  
  // MARK: UI
  
  let post: Driver<Void>
  let like: Driver<Void>
  let changePassword: Driver<Void>
  let passwordChanged: Driver<Bool>
  let terms: Driver<Void>
  let privacy: Driver<Void>
  let logout: Driver<Bool>
  let accountRemove: Driver<Void>
  let accountRemoved: Driver<Bool>
  
  // MARK: - Initialize
  
  init() {
    
    post = myPostButtonDidTapped
      .asDriver(onErrorJustReturn: ())
    
    like = myLikeButtonDidTapped
      .asDriver(onErrorJustReturn: ())
    
    changePassword = changePasswordButtonDidTapped
      .asDriver(onErrorJustReturn: ())
    
    passwordChanged = requestPasswordChange
      .flatMapLatest {
        return AuthService.shared.changePassword($0)
      }
      .asDriver(onErrorJustReturn: false)
    
    terms = termsButtonDidTapped
      .asDriver(onErrorJustReturn: ())
    
    privacy = privacyButtonDidTapped
      .asDriver(onErrorJustReturn: ())
    
    logout = logoutButtonDidTapped
      .flatMapLatest {
        return AuthService.shared.logout()
      }
      .asDriver(onErrorJustReturn: false)
    
    accountRemove = accountRemoveButtonDidTapped
      .asDriver(onErrorJustReturn: ())
    
    accountRemoved = requestRemove
      .flatMapLatest {
        return AuthService.shared.removeAccount()
      }
      .asDriver(onErrorJustReturn: false)
  }
  
}
