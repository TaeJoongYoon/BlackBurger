//
//  FirebaseService.swift
//  Burgers
//
//  Created by Tae joong Yoon on 02/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

struct FirebaseService: FirebaseServiceType {
  
  // MARK: Properties
  
  // MARK: Initialize
  
  init() {
    
  }
  
  // MARK: DataTask
  
  func fetchRecentPosts() -> Observable<[Post]> {
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
