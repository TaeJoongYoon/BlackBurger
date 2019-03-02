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
  
  let swipePage =  PublishSubject<Int>()
  let selectedSegmentIndex = PublishSubject<Int>()
  
  // MARK: <- UI
  
  let showView: Driver<Int>
  
  // MARK: - Initialize
  
  init() {
    
    // Paging
    showView = Observable<Int>
      .merge([swipePage, selectedSegmentIndex])
      .map { $0 }
      .asDriver(onErrorJustReturn: 0)
    
  }
  
}
