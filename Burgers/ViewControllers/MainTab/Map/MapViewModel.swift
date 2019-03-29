//
//  MapViewModel.swift
//  Burgers
//
//  Created by Tae joong Yoon on 25/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol MapViewModelType: ViewModelType {

  //Event
  var viewDidLoad: PublishSubject<Void> { get }
  
  // UI
  var restaurants: Driver<[Place]> { get }
  
}

struct MapViewModel: MapViewModelType {
  
  // MARK: -> Event
  let viewDidLoad = PublishSubject<Void>()
  
  // MARK: <- UI
  let restaurants: Driver<[Place]>
  
  // MARK: - Initialize
  
  init() {
    
    restaurants = viewDidLoad
      .flatMapLatest {
        return DatabaseService.shared.fetchRestaurants()
      }
      .asDriver(onErrorJustReturn: [])
    
  }
  
}
