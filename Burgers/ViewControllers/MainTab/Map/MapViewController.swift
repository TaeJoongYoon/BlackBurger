//
//  MapViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 25/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import CoreLocation

import NMapsMap
import RxCocoa
import RxSwift
import Then

final class MapViewController: BaseViewController, ViewType {

  // MARK: Constants
  
  struct Reusable {
    
  }
  
  struct Constant {
    
  }
  
  struct Metric {
    
  }
  
  // MARK: Properties
  
  var viewModel: MapViewModelType!
  
  // MARK: UI

  let mapView = NMFNaverMapView(frame: .zero).then {
    $0.showCompass = true
    $0.showZoomControls = true
    $0.showLocationButton = true
    $0.mapView.locationOverlay.hidden = false
  }
  
  var cameraPosition = NMFCameraUpdate()
  
  var locationManager: CLLocationManager!
  
  // MARK: Setup UI
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = "MAP".localized
    self.view.backgroundColor = .white
    self.tabBarItem.image = UIImage(named: "pin-unselected.png")
    self.tabBarItem.selectedImage = UIImage(named: "pin-selected.png")
    
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
  
  override func setupConstraints() {
    
    self.mapView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeArea.top)
      make.bottom.equalTo(self.view.safeArea.bottom)
      make.left.right.equalTo(self.view)
    }
  
  }
  
  // MARK: - -> Rx Event Binding
  
  func setupEventBinding(){
    
  }
  
  // MARK: - <- Rx UI Binding
  
  func setupUIBinding() {
    
  }
}

extension MapViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last{
      let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
      
      self.mapView.mapView.locationOverlay.location = NMGLatLng(lat: center.latitude, lng: center.longitude)
      
      self.cameraPosition = NMFCameraUpdate(scrollTo: NMGLatLng(lat: center.latitude, lng: center.longitude))
      self.cameraPosition.animation = .easeIn
      self.mapView.mapView.moveCamera(cameraPosition)
      
      self.locationManager.stopUpdatingLocation()
    }
  }
}
