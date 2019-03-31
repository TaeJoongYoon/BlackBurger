//
//  PostListViewModel.swift
//  Burgers
//
//  Created by Tae joong Yoon on 30/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol PostListViewModelType: ViewModelType {
  
  // Event
  var viewWillAppear: PublishSubject<Bool> { get }
  var didCellSelected: PublishSubject<Post> { get }
  
  // UI
  var isNetworking: Driver<Bool> { get }
  var posts: Driver<[Post]> { get }
  var showPost: Driver<Post> { get }
  
}

struct PostListViewModel: PostListViewModelType {
  
  // MARK: -> Event
  
  let viewWillAppear = PublishSubject<Bool>()
  let didCellSelected = PublishSubject<Post>()
  
  // MARK: <- UI
  
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
        return DatabaseService.shared.fetchPosts(isMyPosts: $0)
          .do { onNetworking.onNext(false) }
          .catchError({ error -> Single<[Post]> in
            onError.onNext(error)
            return .never()
          })
        
      }
      .asDriver(onErrorJustReturn: [])
    
    showPost = didCellSelected
      .asDriver(onErrorJustReturn: Post(author: "",
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
