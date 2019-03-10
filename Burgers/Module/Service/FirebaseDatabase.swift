//
//  FirebaseDatabase.swift
//  Burgers
//
//  Created by Tae joong Yoon on 10/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import FirebaseFirestore
import RxCocoa
import RxSwift

class DatabaseService: DatabaseServiceType {
  
  // MARK: Properties
  
  static let shared = DatabaseService()
  
  var db = Firestore.firestore()
  
  var from = 0
  
  // MARK: Initialize
  
  private init() { }
  
  // MARK: Datatask
  
  func writePost(name: String, completion: @escaping () -> Void) {
    db.collection("posts").addDocument(data: [
      "name": name
    ]) { err in
      if let err = err {
        log.error(err)
      } else {
        completion()
      }
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

