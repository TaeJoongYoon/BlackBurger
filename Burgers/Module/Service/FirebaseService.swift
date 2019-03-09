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

class FirebaseService: FirebaseServiceType {
  
  // MARK: Properties
  
  static let shared = FirebaseService()
  var from = 0
  
  // MARK: Initialize
  
  private init() { }
  
  // MARK: DataTask
  
  func login(email: String, password: String) -> Observable<Bool> {
    return Observable.create { observer in
      Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
        
        if user != nil {
          observer.onNext(true)
        } else {
          observer.onNext(false)
        }
        
        observer.onCompleted()
      }
      
      return Disposables.create()
    }
  }
  
  func signup(email: String, password: String) -> Observable<Bool> {
    return Observable.create { observer in
      Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
        
        if authResult?.user != nil {
          observer.onNext(true)
        } else {
          observer.onNext(false)
        }
        
        observer.onCompleted()
      }
      
      return Disposables.create()
    }
  }
  
  func fetchRecentPosts(loading: Loading) -> Observable<[Post]> {
    
    switch loading {
    case .refresh:
      from = 0
    case .loadMore:
      from += 20
    }
    
    return Observable.create { observer -> Disposable in
      
      var ps = [Post]()
      
      for i in self.from..<self.from+20 {
        ps.append(Post(name: String(i)))
      }
      
      observer.onNext(ps)
      observer.onCompleted()
      
      return Disposables.create()
    }
  }
  
  func fetchPopularPosts() -> Observable<[Post]> {
    return Observable.create { observer -> Disposable in
      
      var ps = [Post]()
      
      for i in 1...20 {
        ps.append(Post(name: String(i)))
      }
      
      observer.onNext(ps)
      observer.onCompleted()
      
      return Disposables.create()
    }
  }
  
}
