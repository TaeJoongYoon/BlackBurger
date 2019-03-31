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
  var viewWillAppear: PublishSubject<Void> { get }
  var willDisplayCell: PublishSubject<Int> { get }
  
  // UI
  var setView: Driver<Void> { get }
  var currentPage: Driver<Int> { get }
  
}

struct PostDetailViewModel: PostDetailViewModelType {
  
  // MARK: -> Event
  
  let viewWillAppear = PublishSubject<Void>()
  let willDisplayCell = PublishSubject<Int>()
  
  // MARK: <- UI
  
  let setView: Driver<Void>
  let currentPage: Driver<Int>
  
  init() {
    
    setView = viewWillAppear
      .asDriver(onErrorJustReturn: ())
    
    currentPage = willDisplayCell
      .asDriver(onErrorJustReturn: 0)
      
    
  }
  
}
