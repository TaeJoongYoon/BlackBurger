//
//  FirebaseServiceType.swift
//  Burgers
//
//  Created by Tae joong Yoon on 02/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxSwift

protocol FirebaseServiceType {
  func login(email: String, password: String) -> Observable<Bool>
  func signup(email: String, password: String) -> Observable<Bool>
  func fetchRecentPosts(_: Int) -> Observable<[Post]>
  func fetchPopularPosts() -> Observable<[Post]>
}
