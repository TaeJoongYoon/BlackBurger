//
//  SuggestedViewModel.swift
//  Burgers
//
//  Created by Tae joong Yoon on 25/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol SuggestedViewModelInputsType {
  var didTappedAddButton: PublishSubject<Void> { get }
}

protocol SuggestedViewModelOutputstype {
  var add: Driver<Void> { get }
}

protocol SuggestedViewModelType: ViewModelType {
  var inputs: SuggestedViewModelInputsType { get }
  var outputs: SuggestedViewModelOutputstype { get }
}

final class SuggestedViewModel: SuggestedViewModelType, SuggestedViewModelInputsType, SuggestedViewModelOutputstype {
  
  var inputs: SuggestedViewModelInputsType { return self }
  var outputs: SuggestedViewModelOutputstype { return self}
  
  // MARK: -> Event
  
  let didTappedAddButton = PublishSubject<Void>()
  
  // MARK: <- UI
  
  let add: Driver<Void>
  
  // MARK: - Initialize
  
  init() {
    
    add = didTappedAddButton
      .asDriver(onErrorJustReturn: ())
    
    
  }
  
}
