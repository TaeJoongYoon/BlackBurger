//
//  FirebaseService.swift
//  Burgers
//
//  Created by Tae joong Yoon on 02/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth
import RxCocoa
import RxSwift

class AuthService: AuthServiceType {

  // MARK: Properties
  
  static let shared = AuthService()
  var from = 0
  
  // MARK: Initialize
  
  private init() { }
  
  // MARK: DataTask
  
  func login(email: String, password: String) -> Single<Bool> {
    return Single<Bool>.create { single in
      Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
        if user != nil {
          setCredential(email: email, password: password)
          
          single(.success(true))
        } else {
          single(.success(false))
        }
      }
      
      return Disposables.create()
    }
  }
  
  func logout() -> Single<Bool>  {
    return Single<Bool>.create { single in
      let firebaseAuth = Auth.auth()
      FBSDKLoginManager().logOut()
      do {
        try firebaseAuth.signOut()
        resetUserInfo()
        single(.success(true))
      } catch let signOutError as NSError {
        log.error("Error signing out: \(signOutError)")
        single(.success(false))
      }
      return Disposables.create()
    }
  }
  
  func signup(email: String, password: String) -> Single<Bool> {
    return Single<Bool>.create { single in
      Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
        if authResult?.user != nil {
          setCredential(email: email, password: password)
          
          single(.success(true))
        } else {
          single(.success(false))
        }
      }
      
      return Disposables.create()
    }
  }
  
  func changePassword(_ newPassword: String) -> Single<Bool> {
    return Single<Bool>.create { single in
      Auth.auth().currentUser?.reauthenticateAndRetrieveData(with: credential()) { result, error in
        if let error = error {
          log.error(error)
          single(.success(false))
        } else {
          result?.user.updatePassword(to: newPassword) { error in
            if error == nil {
              setPassword(newPassword: newPassword)
              single(.success(true))
            } else {
              log.error(error!)
              single(.success(false))
            }
          }
        }
      }
      return Disposables.create()
    }
  }
  
  func removeAccount() -> Single<Bool> {
    return Single<Bool>.create { single in
      Auth.auth().currentUser?.reauthenticateAndRetrieveData(with: credential()) { result, error in
        if let error = error {
          log.error(error)
          single(.success(false))
        } else {
          DatabaseService.shared.removeAll(from: (Auth.auth().currentUser?.email)!)
          
          result?.user.delete { error in
            if let error = error {
              log.error(error)
              single(.success(false))
            } else {
              
              let firebaseAuth = Auth.auth()
              FBSDKLoginManager().logOut()
              do {
                try firebaseAuth.signOut()
                resetUserInfo()
                single(.success(true))
              } catch let signOutError as NSError {
                log.error("Error signing out: \(signOutError)")
                single(.success(false))
              }
              
            }
          }
        }
      }
      return Disposables.create()
    }
  }
  
}
