//
//  NewViewModel.swift
//  Burgers
//
//  Created by Tae joong Yoon on 02/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift

typealias PostsData = SectionModel<String, Post>

protocol RecentViewModelType: ViewModelType {
  
  // Event
  var viewWillAppear: PublishSubject<Void> { get }
  var didPulltoRefresh: PublishSubject<Void> { get }
  var didCellSelected: PublishSubject<Post> { get }
  var isReachedBottom: PublishSubject<Void> { get }
  
  // UI
  var isNetworking: Driver<Bool> { get }
  var posts: Driver<[PostsData]> { get }
  var showPost: Driver<String> { get }
  
}

struct RecentViewModel: RecentViewModelType {
  
  // MARK: Properties
  // MARK: -> Event
  
  let viewWillAppear = PublishSubject<Void>()
  let didPulltoRefresh = PublishSubject<Void>()
  let didCellSelected = PublishSubject<Post>()
  let isReachedBottom = PublishSubject<Void>()
  
  // MART: <- UI
  
  let isNetworking: Driver<Bool>
  let posts: Driver<[PostsData]>
  let showPost: Driver<String>
  
  // MARK: - Initialize
  
  init(firebaseService: FirebaseService = FirebaseService()) {
    
    let onNetworking = PublishSubject<Bool>()
    isNetworking = onNetworking.asDriver(onErrorJustReturn: false)
    
    let onError = PublishSubject<Error>()
    
    posts = Observable<Void>
      .merge([viewWillAppear, didPulltoRefresh])
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
      .do(onNext: {_ in onNetworking.onNext(true)})
      .flatMapLatest {
        return firebaseService.fetchRecentPosts(20)
          .do { onNetworking.onNext(false) }
          .catchError({ error -> Observable<[Post]> in
            onError.onNext(error)
            return .never()
          })
      }
      .map { [PostsData(model: "", items: $0)] }
      .asDriver(onErrorJustReturn: [])
   
    showPost = didCellSelected
      .map { $0.name }
      .asDriver(onErrorJustReturn: "")
  }
  
}
