//
//  PostListViewModel.swift
//  Burgers
//
//  Created by Tae joong Yoon on 30/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol PostListViewModelInputsType {
  var viewWillAppear: PublishSubject<Bool> { get }
  var didCellSelected: PublishSubject<Post> { get }
}

protocol PostListViewModelOutputsType {
  var isNetworking: Driver<Bool> { get }
  var posts: Driver<[Post]> { get }
  var showPost: Driver<Post> { get }
}

protocol PostListViewModelType: ViewModelType {
  var inputs: PostListViewModelInputsType { get }
  var outputs: PostListViewModelOutputsType { get }
}

final class PostListViewModel: PostListViewModelType, PostListViewModelInputsType, PostListViewModelOutputsType {
  
  var inputs: PostListViewModelInputsType { return self }
  var outputs: PostListViewModelOutputsType { return self }
  
  // MARK: Input
  
  let viewWillAppear = PublishSubject<Bool>()
  let didCellSelected = PublishSubject<Post>()
  
  // MARK: Output
  
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
      .asDriver(onErrorJustReturn: Post(id: "",
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
