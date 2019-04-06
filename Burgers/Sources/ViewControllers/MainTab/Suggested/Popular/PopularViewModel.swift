//
//  Top20ViewModel.swift
//  Burgers
//
//  Created by Tae joong Yoon on 02/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol PopularViewModelInputsType {
  var viewWillAppear: PublishSubject<Void> { get }
  var didPulltoRefresh: PublishSubject<Void> { get }
  var didCellSelected: PublishSubject<Post> { get }
}

protocol PopularViewModelOutputsType {
  var isNetworking: Driver<Bool> { get }
  var posts: Driver<[Post]> { get }
  var showPost: Driver<Post> { get }
}

protocol PopularViewModelType: ViewModelType {
  var inputs: PopularViewModelInputsType { get }
  var outputs: PopularViewModelOutputsType { get}
}

final class PopularViewModel: PopularViewModelType, PopularViewModelInputsType, PopularViewModelOutputsType {
  
  var inputs: PopularViewModelInputsType { return self }
  var outputs: PopularViewModelOutputsType { return self }
  
  // MARK: Input
  
  let viewWillAppear = PublishSubject<Void>()
  let didPulltoRefresh = PublishSubject<Void>()
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
    
    posts = Observable<Void>
      .merge([viewWillAppear, didPulltoRefresh])
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
      .do(onNext: {_ in onNetworking.onNext(true)})
      .flatMapLatest {
        return DatabaseService.shared.fetchPopularPosts()
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
