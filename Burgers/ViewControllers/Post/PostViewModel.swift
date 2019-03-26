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
  
  // UI
  var isNetworking: Driver<Bool> { get }
  var places: Driver<[Place]> { get }
  var selectedPlace: Driver<String> { get }
  var writeisEnabled: Driver<Bool> { get }
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
  
  // MARK: <- UI
  
  let isNetworking: Driver<Bool>
  let places: Driver<[Place]>
  let selectedPlace: Driver<String>
  let writeisEnabled: Driver<Bool>
  let writed: Driver<Bool>
  
  
  init(images: [PHAsset]) {
    
    self.images = images
    
    let onNetworking = PublishSubject<Bool>()
    isNetworking = onNetworking.asDriver(onErrorJustReturn: false)
    
    places = Observable.combineLatest(query, coordinate)
      .flatMapLatest { query, coordinate in
        return NaverAPIService.shared.fetchPlaces(query: query, coordinate: coordinate)
      }
      .asDriver(onErrorJustReturn: [])
    
    
    selectedPlace = didCellSelected
      .map { $0.name }
      .asDriver(onErrorJustReturn: "")
    
    writeisEnabled = Observable.combineLatest(query, text)
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
                                               query.asObservable()))
      .flatMapLatest {
        return DatabaseService.shared.writePost(images: $0.0,
                                                rating: $0.1,
                                                content: $0.2,
                                                restaurant: $0.3)
          .do { onNetworking.onNext(false) }
      }
      .asDriver(onErrorJustReturn: false)
  }
  
}
