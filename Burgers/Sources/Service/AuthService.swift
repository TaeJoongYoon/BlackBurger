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
          UserDefaults.standard.set(email, forKey: "email")
          UserDefaults.standard.set(password, forKey: "password")
          UserDefaults.standard.synchronize()
          
          single(.success(true))
        } else {
          single(.success(false))
        }
      }
      
      return Disposables.create()
    }
  }
  
  func logout() {
    let firebaseAuth = Auth.auth()
    FBSDKLoginManager().logOut()
    do {
      try firebaseAuth.signOut()
      UserDefaults.standard.removeObject(forKey: "email")
      UserDefaults.standard.removeObject(forKey: "password")
      UserDefaults.standard.removeObject(forKey: "token")
      UserDefaults.standard.synchronize()
      
    } catch let signOutError as NSError {
      log.error("Error signing out: \(signOutError)")
    }
  }
  
  func signup(email: String, password: String) -> Single<Bool> {
    return Single<Bool>.create { single in
      Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
        if authResult?.user != nil {
          UserDefaults.standard.set(email, forKey: "email")
          UserDefaults.standard.set(password, forKey: "password")
          UserDefaults.standard.synchronize()
          
          single(.success(true))
        } else {
          single(.success(false))
        }
      }
      
      return Disposables.create()
    }
  }
  
  func changePassword(_ newPassword: String, success: @escaping () -> Void) {
    
    var credential: AuthCredential
    
    if UserDefaults.standard.string(forKey: "email") != nil {
      credential = EmailAuthProvider.credential(
        withEmail: UserDefaults.standard.string(forKey: "email")!,
        password: UserDefaults.standard.string(forKey: "password")!
      )
    } else {
      credential = FacebookAuthProvider.credential(
        withAccessToken: UserDefaults.standard.string(forKey: "token")!
      )
    }
    
    Auth.auth().currentUser?.reauthenticateAndRetrieveData(with: credential) { result, error in
      if let error = error {
        log.error(error)
      } else {
        result?.user.updatePassword(to: newPassword) { error in
          if error == nil {
            UserDefaults.standard.set(newPassword, forKey: "password")
            UserDefaults.standard.synchronize()
            success()
          } else {
            log.error(error ?? "NONE")
          }
        }
      }
    }
  }
  
  func removeAccount(_ success: @escaping () -> Void) {
    
    let author = (Auth.auth().currentUser?.email)!
    var credential: AuthCredential
    
    if UserDefaults.standard.string(forKey: "email") != nil {
      credential = EmailAuthProvider.credential(
        withEmail: UserDefaults.standard.string(forKey: "email")!,
        password: UserDefaults.standard.string(forKey: "password")!
      )
    } else {
      credential = FacebookAuthProvider.credential(
        withAccessToken: UserDefaults.standard.string(forKey: "token")!
      )
    }
    
    Auth.auth().currentUser?.reauthenticateAndRetrieveData(with: credential) { result, error in
      if let error = error {
        log.error(error)
      } else {
        DatabaseService.shared.removeAll(from: author)
        
        result?.user.delete {error in
          if let error = error {
            log.error(error)
          } else {

            let firebaseAuth = Auth.auth()
            FBSDKLoginManager().logOut()
            do {
              try firebaseAuth.signOut()

              UserDefaults.standard.removeObject(forKey: "email")
              UserDefaults.standard.removeObject(forKey: "password")
              UserDefaults.standard.removeObject(forKey: "token")
              UserDefaults.standard.synchronize()

            } catch let signOutError as NSError {
              log.error("Error signing out: \(signOutError)")
            }

            success()
          }
        }
      }
    }
  }
  
}
