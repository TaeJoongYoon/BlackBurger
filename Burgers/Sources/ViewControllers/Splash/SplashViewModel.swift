//
//  SplashViewModel.swift
//  Burgers
//
//  Created by Tae joong Yoon on 06/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import FirebaseAuth
import RxCocoa
import RxSwift

protocol SplashViewModelType: ViewModelType {
  
  // Event
  var viewWillAppear: PublishSubject<Void> { get }
  var checkIfAuthenticated: PublishSubject<Void> { get }
  
  // UI
  var versionCheck: Driver<(Bool, String)> { get }
  var isAuthenticated: Driver<Bool> { get }
  
}

struct SplashViewModel: SplashViewModelType {
  
  // MARK: -> Event
  let checkIfAuthenticated = PublishSubject<Void>()
  let viewWillAppear = PublishSubject<Void>()
  
  // MARK: <- UI
  let versionCheck: Driver<(Bool, String)>
  let isAuthenticated: Driver<Bool>
  
  // MARK: - Initialize
  
  init() {
    
    versionCheck = viewWillAppear
      .flatMapLatest {
        return Single<(Bool, String)>.create { single in
          // Version Check
          RemoteConfigManager.shared.launching(completionHandler: { (config) in
          }, forceUpdate: { (forceUpdate, string) in
            if !forceUpdate {
              log.verbose("Update checked")
              single(.success((true, "")))
            } else {
              log.verbose("Update required")
              single(.success((false, string)))
            }
          })
          
          return Disposables.create()
        }
      }
      .asDriver(onErrorJustReturn: (false,""))
    
    isAuthenticated = checkIfAuthenticated.map {
      return Auth.auth().currentUser != nil
      }
      .asDriver(onErrorJustReturn: false)
    
  }
  
}
