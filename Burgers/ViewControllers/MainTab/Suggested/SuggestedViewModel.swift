//
//  SuggestedViewModel.swift
//  Burgers
//
//  Created by Tae joong Yoon on 25/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol SuggestedViewModelType: ViewModelType {
  
  // Event
  var didTappedAddButton: PublishSubject<Void> { get }
  var swipePage: PublishSubject<Int> { get }
  var selectedSegmentIndex: PublishSubject<Int> { get }
  
  // UI
  var add: Driver<Void> { get }
  var showView: Driver<Int> { get }
  
}

struct SuggestedViewModel: SuggestedViewModelType {
  
  // MARK: Properties
  // MARK: -> Event
  
  let didTappedAddButton = PublishSubject<Void>()
  let swipePage =  PublishSubject<Int>()
  let selectedSegmentIndex = PublishSubject<Int>()
  
  // MARK: <- UI
  
  let add: Driver<Void>
  let showView: Driver<Int>
  
  // MARK: - Initialize
  
  init() {
    
    add = didTappedAddButton
      .asDriver(onErrorJustReturn: ())
    
    // Paging
    showView = Observable<Int>
      .merge([swipePage, selectedSegmentIndex])
      .map { $0 }
      .asDriver(onErrorJustReturn: 0)
    
  }
  
}
