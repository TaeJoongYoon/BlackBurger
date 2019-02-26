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
  var swipePage: PublishSubject<Int> { get }
  var selectedSegmentIndex: PublishSubject<Int> { get }
  
  // UI
  var showView: Driver<Int> { get }
}

struct SuggestedViewModel: SuggestedViewModelType {
  
  // MARK: Properties
  // MARK: -> Event
  
  var swipePage =  PublishSubject<Int>()
  var selectedSegmentIndex = PublishSubject<Int>()
  
  // MARK: <- UI
  
  var showView: Driver<Int>
  
  // MARK: - Initialize
  
  init() {
    
    // Paging
    
    showView = Observable<Int>
      .merge([swipePage, selectedSegmentIndex])
      .map { $0 }
      .asDriver(onErrorJustReturn: 0)
  }
  
}
