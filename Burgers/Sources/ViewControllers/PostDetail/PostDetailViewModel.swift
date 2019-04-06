//
//  PostDetailViewModel.swift
//  Burgers
//
//  Created by Tae joong Yoon on 24/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol PostDetailViewModelInputsType {
  var viewWillAppear: PublishSubject<String> { get }
  var willDisplayCell: PublishSubject<Int> { get }
  var id: BehaviorRelay<String> { get }
  var text: PublishSubject<String> { get }
  var requestLike: PublishSubject<(String, Bool)> { get }
  var moreButtonDidTapped: PublishSubject<Void> { get }
  var doneButtonDidTapped: PublishSubject<Void> { get }
  func requestDelete(id: String)
}

protocol PostDetailViewModelOutputsType {
  var setView: Driver<Post> { get }
  var currentPage: Driver<Int> { get }
  var liked: Driver<Int> { get }
  var actionSheet: Driver<Void> { get }
  var edit: Driver<Bool> { get }
  var deleted: Driver<Bool> { get }
}

protocol PostDetailViewModelType: ViewModelType {
  var inputs: PostDetailViewModelInputsType { get }
  var outputs: PostDetailViewModelOutputsType { get }
}

final class PostDetailViewModel: PostDetailViewModelType, PostDetailViewModelInputsType, PostDetailViewModelOutputsType {
  
  var inputs: PostDetailViewModelInputsType { return self }
  var outputs: PostDetailViewModelOutputsType { return self }
  
  // MARK: Input
  
  let viewWillAppear = PublishSubject<String>()
  let willDisplayCell = PublishSubject<Int>()
  let id = BehaviorRelay<String>(value: "")
  let text = PublishSubject<String>()
  let requestLike = PublishSubject<(String, Bool)>()
  let moreButtonDidTapped = PublishSubject<Void>()
  let doneButtonDidTapped = PublishSubject<Void>()
  
  private let _requestDelete = ReplaySubject<String>.create(bufferSize: 1)
  func requestDelete(id: String) {
    self._requestDelete.onNext(id)
  }
  
  // MARK: Output
  
  let setView: Driver<Post>
  let currentPage: Driver<Int>
  let liked: Driver<Int>
  let actionSheet: Driver<Void>
  let edit: Driver<Bool>
  let deleted: Driver<Bool>
  
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
    
    actionSheet = moreButtonDidTapped
      .asDriver(onErrorJustReturn: ())
    
    deleted = self._requestDelete
      .flatMapLatest {
        return DatabaseService.shared.delete(id: $0)
      }
      .asDriver(onErrorJustReturn: false)
    
    edit = doneButtonDidTapped
      .withLatestFrom(Observable.combineLatest(id.asObservable(),
                                               text.asObservable()))
      .flatMapLatest {
        return DatabaseService.shared.edit(id: $0.0, newContent: $0.1)
      }
      .asDriver(onErrorJustReturn: false)
    
  }
  
}
