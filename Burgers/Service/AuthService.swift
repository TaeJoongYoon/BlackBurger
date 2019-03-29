//
//  FirebaseService.swift
//  Burgers
//
//  Created by Tae joong Yoon on 02/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import FirebaseAuth
import RxCocoa
import RxSwift

class AuthService: AuthServiceType {
  
  // MARK: Properties
  
  static let shared = AuthService()
  let user = Auth.auth().currentUser
  var from = 0
  
  // MARK: Initialize
  
  private init() { }
  
  // MARK: DataTask
  
  func login(email: String, password: String) -> Single<Bool> {
    return Single<Bool>.create { single in
      Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
        if user != nil {
          single(.success(true))
        } else {
          single(.success(false))
        }
      }
      
      return Disposables.create()
    }
  }
  
  func signup(email: String, password: String) -> Single<Bool> {
    return Single<Bool>.create { single in
      Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
        if authResult?.user != nil {
          single(.success(true))
        } else {
          single(.success(false))
        }
      }
      
      return Disposables.create()
    }
  }
}
