//
//  PostDetailViewModel.swift
//  Burgers
//
//  Created by Tae joong Yoon on 24/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol PostDetailViewModelType: ViewModelType {
  
  // Event
  var viewWillAppear: PublishSubject<String> { get }
  var willDisplayCell: PublishSubject<Int> { get }
  var requestLike: PublishSubject<(String, Bool)> { get }
  
  // UI
  var setView: Driver<Post> { get }
  var currentPage: Driver<Int> { get }
  var liked: Driver<Int> { get }
  
}

struct PostDetailViewModel: PostDetailViewModelType {
  
  // MARK: -> Event
  
  let viewWillAppear = PublishSubject<String>()
  let willDisplayCell = PublishSubject<Int>()
  let requestLike = PublishSubject<(String, Bool)>()
  
  // MARK: <- UI
  
  let setView: Driver<Post>
  let currentPage: Driver<Int>
  let liked: Driver<Int>
  
  init() {
    
    setView = viewWillAppear
      .flatMapLatest {
        return DatabaseService.shared.post($0)
      }
      .asDriver(onErrorJustReturn: Post(id: "",
                                        author: "",
                                        content: "",
                                        rating: 0.0,
                                        likes: 0,
                                        likeUser: [],
                                        imageURLs: [],
                                        restaurant: "",
                                        address: "",
                                        createdAt: Date()))
    
    currentPage = willDisplayCell
      .asDriver(onErrorJustReturn: 0)
      
    liked = requestLike
      .flatMapLatest {
        return DatabaseService.shared.like(id: $0.0, liked: $0.1)
      }
      .asDriver(onErrorJustReturn: 0)
  }
  
}
