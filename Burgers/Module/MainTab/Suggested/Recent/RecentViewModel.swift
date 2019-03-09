//
//  NewViewModel.swift
//  Burgers
//
//  Created by Tae joong Yoon on 02/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol RecentViewModelType: ViewModelType {
  
  // Event
  var viewWillAppear: PublishSubject<Void> { get }
  var didPulltoRefresh: PublishSubject<Void> { get }
  var didCellSelected: PublishSubject<Post> { get }
  var isReachedBottom: PublishSubject<Bool> { get }
  
  // UI
  var isNetworking: Driver<Bool> { get }
  var posts: Driver<[Post]> { get }
  var postss: Driver<[Post]> { get }
  var showPost: Driver<String> { get }
  
}

struct RecentViewModel: RecentViewModelType {
  
  // MARK: Properties
  // MARK: -> Event
  
  let viewWillAppear = PublishSubject<Void>()
  let didPulltoRefresh = PublishSubject<Void>()
  let didCellSelected = PublishSubject<Post>()
  let isReachedBottom = PublishSubject<Bool>()
  
  // MART: <- UI
  
  let isNetworking: Driver<Bool>
  let posts: Driver<[Post]>
  let postss: Driver<[Post]>
  let showPost: Driver<String>
  
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
        return FirebaseService.shared.fetchRecentPosts(loading: .refresh)
          .do { onNetworking.onNext(false) }
          .catchError({ error -> Observable<[Post]> in
            onError.onNext(error)
            return .never()
          })
      }
      .asDriver(onErrorJustReturn: [])
    
    postss = isReachedBottom
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
      .do(onNext: { _ in onNetworking.onNext(true)})
      .flatMapLatest { _ in
        return FirebaseService.shared.fetchRecentPosts(loading: .loadMore)
          .do { onNetworking.onNext(false) }
          .catchError({ error -> Observable<[Post]> in
            onError.onNext(error)
            return .never()
          })
      }
      .asDriver(onErrorJustReturn: [])
   
    showPost = didCellSelected
      .map { $0.name }
      .asDriver(onErrorJustReturn: "")
  }
  
}
