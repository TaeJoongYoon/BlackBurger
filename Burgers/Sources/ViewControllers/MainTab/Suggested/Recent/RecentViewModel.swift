//
//  NewViewModel.swift
//  Burgers
//
//  Created by Tae joong Yoon on 02/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol RecentViewModelInputsType {
  var viewWillAppear: PublishSubject<Void> { get }
  var didPulltoRefresh: PublishSubject<Void> { get }
  var didCellSelected: PublishSubject<Post> { get }
  var isReachedBottom: PublishSubject<Bool> { get }
}

protocol RecentViewModelOutputsType {
  var isNetworking: Driver<Bool> { get }
  var posts: Driver<[Post]> { get }
  var loadMore: Driver<[Post]> { get }
  var showPost: Driver<Post> { get }
}

protocol RecentViewModelType: ViewModelType {
  var inputs: RecentViewModelInputsType { get }
  var outputs: RecentViewModelOutputsType { get }
}

final class RecentViewModel: RecentViewModelType, RecentViewModelInputsType, RecentViewModelOutputsType {
  
  var inputs: RecentViewModelInputsType { return self }
  var outputs: RecentViewModelOutputsType { return self }
  
  // MARK: Input
  
  let viewWillAppear = PublishSubject<Void>()
  let didPulltoRefresh = PublishSubject<Void>()
  let didCellSelected = PublishSubject<Post>()
  let isReachedBottom = PublishSubject<Bool>()
  
  // MART: Output
  
  let isNetworking: Driver<Bool>
  let posts: Driver<[Post]>
  let loadMore: Driver<[Post]>
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
        return DatabaseService.shared.fetchRecentPosts(loading: .refresh)
          .do { onNetworking.onNext(false) }
          .catchError({ error -> Single<[Post]> in
            onError.onNext(error)
            return .never()
          })
      }
      .asDriver(onErrorJustReturn: [])
    
    loadMore = isReachedBottom
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
      .do(onNext: { _ in onNetworking.onNext(true)})
      .flatMapLatest { _ in
        return DatabaseService.shared.fetchRecentPosts(loading: .loadMore)
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
