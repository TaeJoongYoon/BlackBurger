//
//  FirebaseServiceType.swift
//  Burgers
//
//  Created by Tae joong Yoon on 02/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxSwift

protocol AuthServiceType {
  func login(email: String, password: String) -> Observable<Bool>
  func signup(email: String, password: String) -> Observable<Bool>
}

protocol DatabaseServiceType {
  func fetchRecentPosts(loading: Loading) -> Observable<[Post]>
  func fetchPopularPosts() -> Observable<[Post]>
}

protocol NaverAPIServiceType {
  func fetchPlaces(query: String, coordinate: String) -> Single<[Place]>
}
