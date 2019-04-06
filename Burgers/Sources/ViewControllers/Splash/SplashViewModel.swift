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

protocol SplashViewModelInputsType {
  var viewWillAppear: PublishSubject<Void> { get }
  func checkIfAuthenticated()
}

protocol SplashViewModelOutputsType {
  var versionCheck: Driver<(Bool, Bool, String)> { get }
  var isAuthenticated: Driver<Bool> { get }
}

protocol SplashViewModelType: ViewModelType {
  var inputs: SplashViewModelInputsType { get }
  var outputs: SplashViewModelOutputsType { get }
}

final class SplashViewModel: SplashViewModelType, SplashViewModelInputsType, SplashViewModelOutputsType {
  
  var inputs: SplashViewModelInputsType { return self }
  var outputs: SplashViewModelOutputsType { return self }
  
  // MARK: Input
  
  let viewWillAppear = PublishSubject<Void>()
  
  private let _checkIfAuthenticated = ReplaySubject<Void>.create(bufferSize: 1)
  func checkIfAuthenticated() {
    _checkIfAuthenticated.onNext(())
  }
  
  // MARK: Ouput
  
  let versionCheck: Driver<(Bool, Bool, String)>
  let isAuthenticated: Driver<Bool>
  
  // MARK: - Initialize
  
  init() {
    
    versionCheck = viewWillAppear
      .flatMapLatest {
        return Single<(Bool, Bool, String)>.create { single in
          // Version Check
          RemoteConfigManager.shared.launching(completionHandler: { (config) in
          }, update: { (forceUpdate, optionUpdate) in
            single(.success((forceUpdate, optionUpdate, "https://itunes.apple.com/app/id\(PrivateKey.appID)?mt=8")))
          })
          return Disposables.create()
        }
      }
      .asDriver(onErrorJustReturn: (false,false,"https://itunes.apple.com/app/id\(PrivateKey.appID)?mt=8"))
    
    isAuthenticated = _checkIfAuthenticated.map {
      return Auth.auth().currentUser != nil
      }
      .asDriver(onErrorJustReturn: false)
    
  }
  
}
