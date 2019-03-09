//
//  Top20ViewModel.swift
//  Burgers
//
//  Created by Tae joong Yoon on 02/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol PopularViewModelType: ViewModelType {
  
  // Event
  var viewWillAppear: PublishSubject<Void> { get }
  var didPulltoRefresh: PublishSubject<Void> { get }
  var didCellSelected: PublishSubject<Post> { get }
  
  // UI
  var isNetworking: Driver<Bool> { get }
  var posts: Driver<[Post]> { get }
  var showPost: Driver<String> { get }
  
}

struct PopularViewModel: PopularViewModelType {
  
  // MARK: Properties
  // MARK: -> Event
  
  let viewWillAppear = PublishSubject<Void>()
  let didPulltoRefresh = PublishSubject<Void>()
  let didCellSelected = PublishSubject<Post>()
  
  // MART: <- UI
  
  let isNetworking: Driver<Bool>
  let posts: Driver<[Post]>
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
        return FirebaseService.shared.fetchPopularPosts()
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
