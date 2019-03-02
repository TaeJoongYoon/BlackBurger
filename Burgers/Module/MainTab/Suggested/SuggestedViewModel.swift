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
  var willAppear: PublishSubject<Void> { get }
  
  // UI
  var showView: Driver<Int> { get }
  var s: Driver<Bool> { get }
}

struct SuggestedViewModel: SuggestedViewModelType {
  
  // MARK: Properties
  // MARK: -> Event
  
  let swipePage =  PublishSubject<Int>()
  let selectedSegmentIndex = PublishSubject<Int>()
  let willAppear = PublishSubject<Void>()
  
  // MARK: <- UI
  
  let showView: Driver<Int>
  let s: Driver<Bool>
  
  // MARK: - Initialize
  
  init() {
    
    // Paging
    showView = Observable<Int>
      .merge([swipePage, selectedSegmentIndex])
      .map { $0 }
      .asDriver(onErrorJustReturn: 0)
    
    s = Observable<Void>.merge([willAppear]).map {true}.asDriver(onErrorJustReturn: false)
  }
  
}
