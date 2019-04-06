//
//  MapViewModel.swift
//  Burgers
//
//  Created by Tae joong Yoon on 25/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol MapViewModelInputsType {
  var viewWillAppear: PublishSubject<Void> { get }
}

protocol MapViewModelOutputsType {
  var restaurants: Driver<[Place]> { get }
}

protocol MapViewModelType: ViewModelType {
  var inputs: MapViewModelInputsType { get }
  var outputs: MapViewModelOutputsType { get }
}

final class MapViewModel: MapViewModelType, MapViewModelInputsType, MapViewModelOutputsType {
  
  var inputs: MapViewModelInputsType { return self }
  var outputs: MapViewModelOutputsType { return self }
  
  // MARK: -> Event
  let viewWillAppear = PublishSubject<Void>()
  
  // MARK: <- UI
  let restaurants: Driver<[Place]>
  
  // MARK: - Initialize
  
  init() {
    
    restaurants = viewWillAppear
      .flatMapLatest {
        return DatabaseService.shared.fetchRestaurants()
      }
      .asDriver(onErrorJustReturn: [])
    
  }
  
}
