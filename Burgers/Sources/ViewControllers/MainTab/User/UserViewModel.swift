//
//  UserViewModel.swift
//  Burgers
//
//  Created by Tae joong Yoon on 25/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol UserViewModelInputsType {
  var myPostButtonDidTapped: PublishSubject<Void> { get }
  var myLikeButtonDidTapped: PublishSubject<Void> { get }
  var changePasswordButtonDidTapped: PublishSubject<Void> { get }
  func requestPasswordChange(newPassword: String)
  var termsButtonDidTapped: PublishSubject<Void> { get }
  var privacyButtonDidTapped: PublishSubject<Void> { get }
  var logoutButtonDidTapped: PublishSubject<Void> { get }
  var accountRemoveButtonDidTapped: PublishSubject<Void> { get }
  func requestRemove()
  var emailButtonDidTapped: PublishSubject<Void> { get }
  var reviewButtonDidTapped: PublishSubject<Void> { get }
}

protocol UserViewModelOutputsType {
  var post: Driver<Void> { get }
  var like: Driver<Void> { get }
  var changePassword: Driver<Void> { get }
  var passwordChanged: Driver<Bool> { get }
  var terms: Driver<Void> { get }
  var privacy: Driver<Void> { get }
  var logout: Driver<Bool> { get }
  var accountRemove: Driver<Void> { get }
  var accountRemoved: Driver<Bool> { get }
  var email: Driver<String> { get }
  var review: Driver<String> { get }
}

protocol UserViewModelType: ViewModelType {
  var inputs: UserViewModelInputsType { get }
  var outputs: UserViewModelOutputsType { get }
  
}

final class UserViewModel: UserViewModelType, UserViewModelInputsType, UserViewModelOutputsType {
  
  var inputs: UserViewModelInputsType { return self }
  var outputs: UserViewModelOutputsType { return self}
  
  // MARK: Input
  
  let myPostButtonDidTapped = PublishSubject<Void>()
  let myLikeButtonDidTapped = PublishSubject<Void>()
  let changePasswordButtonDidTapped = PublishSubject<Void>()

  private let _requestPasswordChange = ReplaySubject<String>.create(bufferSize: 1)
  func requestPasswordChange(newPassword: String) {
    self._requestPasswordChange.onNext(newPassword)
  }
  
  let termsButtonDidTapped = PublishSubject<Void>()
  let privacyButtonDidTapped = PublishSubject<Void>()
  let logoutButtonDidTapped = PublishSubject<Void>()
  let accountRemoveButtonDidTapped = PublishSubject<Void>()
  private let _requestRemove = ReplaySubject<Void>.create(bufferSize: 1)
  func requestRemove() {
    self._requestRemove.onNext(())
  }
  
  let emailButtonDidTapped = PublishSubject<Void>()
  let reviewButtonDidTapped = PublishSubject<Void>()
  
  // MARK: Output
  
  let post: Driver<Void>
  let like: Driver<Void>
  let changePassword: Driver<Void>
  let passwordChanged: Driver<Bool>
  let terms: Driver<Void>
  let privacy: Driver<Void>
  let logout: Driver<Bool>
  let accountRemove: Driver<Void>
  let accountRemoved: Driver<Bool>
  let email: Driver<String>
  let review: Driver<String>
  
  // MARK: - Initialize
  
  init() {
    
    post = myPostButtonDidTapped
      .asDriver(onErrorJustReturn: ())
    
    like = myLikeButtonDidTapped
      .asDriver(onErrorJustReturn: ())
    
    changePassword = changePasswordButtonDidTapped
      .asDriver(onErrorJustReturn: ())
    
    passwordChanged = _requestPasswordChange
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
    
    accountRemoved = _requestRemove
      .flatMapLatest {
        return AuthService.shared.removeAccount()
      }
      .asDriver(onErrorJustReturn: false)
    
    email = emailButtonDidTapped
      .map {
        PrivateKey.developerEmail
      }
      .asDriver(onErrorJustReturn: PrivateKey.developerEmail)
    
    review = reviewButtonDidTapped
      .map {
        "https://itunes.apple.com/app/id\(PrivateKey.appID)?mt=8&action=write-review"
      }
      .asDriver(onErrorJustReturn: PrivateKey.developerEmail)
  }
  
}
