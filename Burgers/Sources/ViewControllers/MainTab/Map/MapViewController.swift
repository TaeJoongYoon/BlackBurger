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

final class MapViewController: BaseViewController {
  
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
  
  override init() {
    super.init()
    self.tabBarItem.image = UIImage(named: "pin-unselected.png")
    self.tabBarItem.selectedImage = UIImage(named: "pin-selected.png")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = "MAP".localized
    let backBarButtton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    self.navigationItem.backBarButtonItem = backBarButtton
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
  
  override func setupConstraints() {
    
    self.mapView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeArea.top)
      make.bottom.equalTo(self.view.safeArea.bottom)
      make.left.right.equalTo(self.view)
    }
  
  }
  
  // MARK: - -> Rx Event Binding
  
  override func eventBinding(){
    
    self.rx.viewWillAppear
      .bind(to: viewModel.inputs.viewWillAppear)
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: - <- Rx UI Binding
  
  override func uiBinding() {
    
    viewModel.outputs.restaurants
      .drive(onNext: { [weak self] in
        self?.setMarkers($0)
      })
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: Action Handler
  
  func setMarkers(_ places: [Place]) {
    for place in places {
      let marker = NMFMarker()
      
      let lat = Double(place.y)
      let lng = Double(place.x)
      
      marker.position = NMGLatLng(lat: lat!, lng: lng!)
      marker.captionText = place.name
      marker.iconPerspectiveEnabled = true
      marker.isHideCollidedSymbols = true
      marker.isHideCollidedMarkers = true
      marker.userInfo = [
        "name": place.name,
        "address": place.jibunAddress,
        "phone_number": place.phoneNumber,
        "lat": lat!,
        "lng": lng!,
        "distance": place.distance,
      ]
      
      marker.touchHandler = { overlay -> Bool in
        let viewController = self.appDelegate.container.resolve(RestaurantViewController.self, argument: overlay.userInfo)!
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
        
        return false
      }
      
      marker.mapView = self.mapView.mapView
    }
  }
  
}

extension MapViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last{
      let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                          longitude: location.coordinate.longitude)
      
      self.mapView.mapView.locationOverlay.location = NMGLatLng(lat: center.latitude,
                                                                lng: center.longitude)
      
      self.cameraPosition = NMFCameraUpdate(scrollTo: NMGLatLng(lat: center.latitude,
                                                                lng: center.longitude))
      self.cameraPosition.animation = .easeIn
      self.mapView.mapView.moveCamera(cameraPosition)
      
      self.locationManager.stopUpdatingLocation()
    }
  }
}
