//
//  FirebaseServiceType.swift
//  Burgers
//
//  Created by Tae joong Yoon on 02/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import Photos

import RxSwift

protocol AuthServiceType {
  func login(email: String, password: String) -> Single<Bool>
  func logout() -> Single<Bool>
  func signup(email: String, password: String) -> Single<Bool>
  func changePassword(_ newPassword: String) -> Single<Bool>
  func removeAccount() -> Single<Bool>
}

protocol DatabaseServiceType {
  func writePost(images: [PHAsset], rating: Double, content: String, restaurant: String, place: Place) -> Single<Bool>
  func fetchRecentPosts(loading: Loading) -> Single<[Post]>
  func fetchPopularPosts() -> Single<[Post]>
  func fetchRestaurants() -> Single<[Place]>
  func fetchPosts(from restaurant: String) -> Single<[Post]>
  func fetchPosts(isMyPosts: Bool) -> Single<[Post]>
  func post(_ id: String) -> Single<Post>
  func like(id: String, liked: Bool) -> Single<Int>
  func removeAll(from author: String)
}

protocol NaverAPIServiceType {
  func fetchPlaces(query: String, coordinate: String) -> Single<NetworkResult<[Place]>>
}
