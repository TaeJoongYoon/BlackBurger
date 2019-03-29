//
//  PostViewModel.swift
//  Burgers
//
//  Created by Tae joong Yoon on 24/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//
import Photos

import RxCocoa
import RxSwift

protocol PostViewModelType: ViewModelType {
  
  // Event
  var query: PublishSubject<String> { get }
  var coordinate: PublishSubject<String> { get }
  var didCellSelected: PublishSubject<Place> { get }
  var rating: BehaviorRelay<Double> { get }
  var text: PublishSubject<String> { get }
  var write: PublishSubject<Void> { get }
  var writeRestaurant: PublishSubject<Place> { get }
  
  // UI
  var isNetworking: Driver<Bool> { get }
  var places: Driver<NetworkResult<[Place]>> { get }
  var selectedPlace: Observable<Place> { get }
  var writeIsEnabled: Driver<Bool> { get }
  var writed: Driver<Bool> { get }
  
}

struct PostViewModel: PostViewModelType {
  
  // MARK: Properties
  
  var images: [PHAsset]
  
  // MARK: -> Event
  
  let query = PublishSubject<String>()
  let coordinate = PublishSubject<String>()
  let didCellSelected = PublishSubject<Place>()
  let rating = BehaviorRelay<Double>(value: 0)
  let text = PublishSubject<String>()
  let write = PublishSubject<Void>()
  let writeRestaurant = PublishSubject<Place>()
  
  // MARK: <- UI
  
  let isNetworking: Driver<Bool>
  let places: Driver<NetworkResult<[Place]>>
  let selectedPlace: Observable<Place>
  let writeIsEnabled: Driver<Bool>
  let writed: Driver<Bool>
  
  // MARK: - Initialize
  
  init(images: [PHAsset]) {
    
    self.images = images
    
    let onNetworking = PublishSubject<Bool>()
    isNetworking = onNetworking.asDriver(onErrorJustReturn: false)
    
    places = Observable.combineLatest(query, coordinate)
      .flatMapLatest { query, coordinate in
        return NaverAPIService.shared.fetchPlaces(query: query, coordinate: coordinate)
      }
      .asDriver(onErrorJustReturn: .none)
    
    
    selectedPlace = didCellSelected
      .asObservable()
    
    writeIsEnabled = Observable.combineLatest(query, text)
      .asObservable()
      .map {
        $0.0.count > 0 && $0.1.count > 0
      }
      .asDriver(onErrorJustReturn: false)
    
    writed = write
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
      .do(onNext: {_ in onNetworking.onNext(true)})
      .withLatestFrom(Observable.combineLatest(Observable.just(self.images),
                                               rating.asObservable(),
                                               text.asObservable(),
                                               query.asObservable(),
                                               didCellSelected.asObservable()))
      .flatMapLatest {
        return DatabaseService.shared.writePost(images: $0.0,
                                                rating: $0.1,
                                                content: $0.2,
                                                restaurant: $0.3,
                                                place: $0.4)
          .do { onNetworking.onNext(false) }
      }
      .asDriver(onErrorJustReturn: false)
    
  }
  
}
