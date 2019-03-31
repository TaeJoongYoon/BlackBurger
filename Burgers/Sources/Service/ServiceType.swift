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
  func logout() -> Void
  func signup(email: String, password: String) -> Single<Bool>
  func changePassword(_ newPassword: String, success: @escaping () -> Void)
  func removeAccount(_ success: @escaping () -> Void)
}

protocol DatabaseServiceType {
  func writePost(images: [PHAsset], rating: Double, content: String, restaurant: String, place: Place) -> Single<Bool>
  func fetchRecentPosts(loading: Loading) -> Single<[Post]>
  func fetchPopularPosts() -> Single<[Post]>
  func fetchRestaurants() -> Single<[Place]>
  func fetchPosts(from restaurant: String) -> Single<[Post]>
  func fetchPosts(isMyPosts: Bool) -> Single<[Post]>
  func removeAll(from author: String)
}

protocol NaverAPIServiceType {
  func fetchPlaces(query: String, coordinate: String) -> Single<NetworkResult<[Place]>>
}
