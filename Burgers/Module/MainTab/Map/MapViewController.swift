//
//  MapViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 25/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import CoreLocation
import MapKit

import RxCocoa
import RxMKMapView
import RxSwift
import Then

final class MapViewController: UIViewController, ViewType {

  // MARK: Constants
  
  struct Reusable {
    
  }
  
  struct Constant {
    
  }
  
  struct Metric {
    
  }
  
  // MARK: Rx
  
  var disposeBag: DisposeBag!
  
  // MARK: Properties
  
  var viewModel: MapViewModelType!
  
  // MARK: UI
  
  let mapView = MKMapView(frame: .zero).then {
    $0.showsUserLocation = true
  }
  
  var locationManager: CLLocationManager!
  
  // MARK: Setup UI
  
  func setupUI() {
    
    self.title = "Map".localized
    self.view.backgroundColor = .white
    
    self.view.addSubview(mapView)
    
    locationManager = CLLocationManager()
    locationManager?.requestWhenInUseAuthorization()
    
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
      locationManager.startUpdatingLocation()
    }
    
  }
  
  // MARK: Setup Constraints
  
  func setupConstraints() {
    
    mapView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeArea.top)
      make.bottom.equalTo(self.view.safeArea.bottom)
      make.left.right.equalTo(self.view)
    }
    
  }
  
  // MARK: - -> Rx Event Binding
  
  func setupEventBinding(){
    
    mapView.rx.didFinishRenderingMap
      .asDriver()
      .drive(onNext: {
        print($0)
      })
      .disposed(by: disposeBag)
    
    mapView.rx.willStartLoadingMap
      .asDriver()
      .drive(onNext: {
        print("map started loadedloading")
      })
      .disposed(by: disposeBag)

    mapView.rx.didFinishLoadingMap
      .asDriver()
      .drive(onNext: {
        print("map finished loading")
      })
      .disposed(by: disposeBag)

    mapView.rx.didFailLoadingMap
      .subscribe({
        print($0.debugDescription)
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - <- Rx UI Binding
  
  func setupUIBinding() {
    
  }
}

extension MapViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last{
      let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
      print("locations = \(center.latitude) \(center.longitude)")
      let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
      mapView.setRegion(region, animated: true)
    }
  }
}
