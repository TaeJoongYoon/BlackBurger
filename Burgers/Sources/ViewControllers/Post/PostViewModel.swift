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

protocol PostViewModelInputsType {
  func photos(assets: [PHAsset])
  var query: PublishSubject<String> { get }
  func coordinate(coordinate: String)
  var didCellSelected: PublishSubject<Place> { get }
  var rating: BehaviorRelay<Double> { get }
  var text: PublishSubject<String> { get }
  var write: PublishSubject<Void> { get }
  var writeRestaurant: PublishSubject<Place> { get }
}

protocol PostViewModelOutputsType {
  var isNetworking: Driver<Bool> { get }
  var places: Observable<NetworkResult<[Place]>> { get }
  var selectedPlace: Observable<Place> { get }
  var writeIsEnabled: Driver<Bool> { get }
  var writed: Driver<Bool> { get }
}

protocol PostViewModelType: ViewModelType {
  var inputs: PostViewModelInputsType { get }
  var outputs: PostViewModelOutputsType { get }
}

final class PostViewModel: PostViewModelType, PostViewModelInputsType, PostViewModelOutputsType {
  
  var inputs: PostViewModelInputsType { return self }
  var outputs: PostViewModelOutputsType { return self }
  
  // MARK: Input
  
  private let _photos = ReplaySubject<[PHAsset]>.create(bufferSize: 1)
  func photos(assets: [PHAsset]) {
    self._photos.onNext(assets)
  }
  let query = PublishSubject<String>()
  private let _coordinate = ReplaySubject<String>.create(bufferSize: 1)
  func coordinate(coordinate: String) {
    self._coordinate.onNext(coordinate)
  }
  let didCellSelected = PublishSubject<Place>()
  let rating = BehaviorRelay<Double>(value: 0)
  let text = PublishSubject<String>()
  let write = PublishSubject<Void>()
  let writeRestaurant = PublishSubject<Place>()
  
  // MARK: Output
  
  let isNetworking: Driver<Bool>
  let places: Observable<NetworkResult<[Place]>>
  let selectedPlace: Observable<Place>
  let writeIsEnabled: Driver<Bool>
  let writed: Driver<Bool>
  
  // MARK: - Initialize
  
  init() {
    
    let onNetworking = PublishSubject<Bool>()
    isNetworking = onNetworking.asDriver(onErrorJustReturn: false)
    
    places = Observable.combineLatest(query, _coordinate)
      .flatMapLatest { query, coordinate in
        return NaverAPIService.shared.fetchPlaces(query: query, coordinate: coordinate)
      }
      .asObservable()
    
    
    selectedPlace = didCellSelected
      .asObservable()
    
    writeIsEnabled = Observable.combineLatest(query, text)
      .asObservable()
      .map {
        $0.0.count > 0 && $0.1.count > 0
      }
      .asDriver(onErrorJustReturn: false)
    
    let writeForm = Observable.combineLatest(_photos.asObservable(),
                                             rating.asObservable(),
                                             text.asObservable(),
                                             query.asObservable(),
                                             didCellSelected.asObservable())
    
    writed = write
      .withLatestFrom(writeForm)
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
      .do(onNext: {_ in onNetworking.onNext(true)})
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
