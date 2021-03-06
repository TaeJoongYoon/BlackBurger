//
//  RestaurantViewModel.swift
//  Burgers
//
//  Created by Tae joong Yoon on 24/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol RestaurantViewModelInputsType {
  var viewWillAppear: PublishSubject<String> { get }
  var didCellSelected: PublishSubject<Post> { get }
}

protocol RestaurantViewModelOutputsType {
  var isNetworking: Driver<Bool> { get }
  var posts: Driver<[Post]> { get }
  var showPost: Driver<Post> { get }
}

protocol RestaurantViewModelType: ViewModelType {
  var inputs: RestaurantViewModelInputsType { get }
  var outputs: RestaurantViewModelOutputsType { get }
}

final class RestaurantViewModel: RestaurantViewModelType, RestaurantViewModelInputsType, RestaurantViewModelOutputsType {
  
  var inputs: RestaurantViewModelInputsType { return self }
  var outputs: RestaurantViewModelOutputsType { return self }
  
  // MARK: Input
  
  let viewWillAppear = PublishSubject<String>()
  let didCellSelected = PublishSubject<Post>()
  
  // MART: Output
  
  let isNetworking: Driver<Bool>
  let posts: Driver<[Post]>
  let showPost: Driver<Post>
  
  // MARK: - Initialize
  
  init() {
    
    let onNetworking = PublishSubject<Bool>()
    isNetworking = onNetworking.asDriver(onErrorJustReturn: false)
    
    let onError = PublishSubject<Error>()
    
    posts = viewWillAppear
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
      .do(onNext: {_ in onNetworking.onNext(true)})
      .flatMapLatest {
        return DatabaseService.shared.fetchPosts(from: $0)
          .do { onNetworking.onNext(false) }
          .catchError({ error -> Single<[Post]> in
            onError.onNext(error)
            return .never()
          })
      }
      .asDriver(onErrorJustReturn: [])
    
    showPost = didCellSelected
      .asDriver(onErrorJustReturn: Post(id:"",
                                        author: "",
                                        content: "",
                                        rating: 0,
                                        likes: 0,
                                        likeUser: [],
                                        imageURLs: [],
                                        restaurant: "",
                                        address: "",
                                        createdAt: Date()))
  }
}
