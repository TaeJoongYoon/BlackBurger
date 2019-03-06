//
//  SplashViewModel.swift
//  Burgers
//
//  Created by Tae joong Yoon on 06/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol SplashViewModelType: ViewModelType {
  
  // Event
  var checkIfAuthenticated: PublishSubject<Void> { get }
  
  // UI
  var isAuthenticated: Driver<Bool> { get }
  
}

struct SplashViewModel: SplashViewModelType {
  
  // MARK: Properties
  // MARK: -> Event
  let checkIfAuthenticated = PublishSubject<Void>()
  
  // MARK: <- UI
  let isAuthenticated: Driver<Bool>
  
  init() {
    
    isAuthenticated = checkIfAuthenticated.map {
      false
    }.asDriver(onErrorJustReturn: false)
    
  }
  
}
