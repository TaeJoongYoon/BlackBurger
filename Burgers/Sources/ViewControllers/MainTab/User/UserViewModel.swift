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
  var termsButtonDidTapped: PublishSubject<Void> { get }
  var privacyButtonDidTapped: PublishSubject<Void> { get }
  var logoutButtonDidTapped: PublishSubject<Void> { get }
  var accountRemoveButtonDidTapped: PublishSubject<Void> { get }
  
  // UI
  var post: Driver<Void> { get }
  var like: Driver<Void> { get }
  var changePassword: Driver<Void> { get }
  var terms: Driver<Void> { get }
  var privacy: Driver<Void> { get }
  var logout: Driver<Void> { get }
  var accountRemove: Driver<Void> { get }
  
}

struct UserViewModel: UserViewModelType {
  
  // MARK: Event
  
  let myPostButtonDidTapped = PublishSubject<Void>()
  let myLikeButtonDidTapped = PublishSubject<Void>()
  let changePasswordButtonDidTapped = PublishSubject<Void>()
  let termsButtonDidTapped = PublishSubject<Void>()
  let privacyButtonDidTapped = PublishSubject<Void>()
  let logoutButtonDidTapped = PublishSubject<Void>()
  let accountRemoveButtonDidTapped = PublishSubject<Void>()
  
  // MARK: UI
  
  let post: Driver<Void>
  let like: Driver<Void>
  let changePassword: Driver<Void>
  let terms: Driver<Void>
  let privacy: Driver<Void>
  let logout: Driver<Void>
  let accountRemove: Driver<Void>
  
  // MARK: - Initialize
  
  init() {
    
    post = myPostButtonDidTapped
      .asDriver(onErrorJustReturn: ())
    
    like = myLikeButtonDidTapped
      .asDriver(onErrorJustReturn: ())
    
    changePassword = changePasswordButtonDidTapped
      .asDriver(onErrorJustReturn: ())
    
    terms = termsButtonDidTapped
      .asDriver(onErrorJustReturn: ())
    
    privacy = privacyButtonDidTapped
      .asDriver(onErrorJustReturn: ())
    
    logout = logoutButtonDidTapped
      .asDriver(onErrorJustReturn: ())
    
    accountRemove = accountRemoveButtonDidTapped
      .asDriver(onErrorJustReturn: ())
    
  }
  
}
