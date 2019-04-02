//
//  Credential.swift
//  Burgers
//
//  Created by Tae joong Yoon on 03/04/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import Foundation

import FBSDKCoreKit
import FirebaseAuth

func credential() -> AuthCredential {
  var authCredential: AuthCredential
  if UserDefaults.standard.string(forKey: "email") != nil {
    
    authCredential = EmailAuthProvider.credential(
      withEmail: UserDefaults.standard.string(forKey: "email")!,
      password: UserDefaults.standard.string(forKey: "password")!
    )
  } else {
    authCredential = FacebookAuthProvider.credential(
      withAccessToken: UserDefaults.standard.string(forKey: "token")!
    )
  }
  
  return authCredential
}

func setCredential(email: String, password: String) {
  UserDefaults.standard.set(email, forKey: "email")
  UserDefaults.standard.set(password, forKey: "password")
  UserDefaults.standard.synchronize()
}

func setPassword(newPassword: String) {
  UserDefaults.standard.set(newPassword, forKey: "password")
  UserDefaults.standard.synchronize()
}

func resetUserInfo() {
  UserDefaults.standard.removeObject(forKey: "email")
  UserDefaults.standard.removeObject(forKey: "password")
  UserDefaults.standard.removeObject(forKey: "token")
  UserDefaults.standard.synchronize()
}
