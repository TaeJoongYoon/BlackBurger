//
//  PostViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 24/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import CoreLocation
import Photos

import Alamofire
import Cosmos
import ReusableKit
import RxCocoa
import RxSwift
import Then
import Toaster

final class PostViewController: BaseViewController {
  
  // MARK: Constants
  
  fileprivate struct Reusable {
    static let TitleCell = ReusableCell<UITableViewCell>()
  }
  
  fileprivate struct Metric {
    static let borderWidth = Double(2)
    static let offset = 20
    static let indicatorAlpha = CGFloat(0.5)
    static let starSize = Double(UIScreen.main.bounds.size.width / 8)
  }
  
  // MARK: Properties
  
  fileprivate let viewModel: PostViewModelType
  fileprivate let locationManager: CLLocationManager
  fileprivate let places = BehaviorRelay<[Place]>(value: [])
  fileprivate var restaurant: Place!
  fileprivate let photos: [PHAsset]
  
  // MARK: UI
  
  let writeButton = UIBarButtonItem(title: "Share".localized, style: .plain, target: self, action: nil).then {
    $0.isEnabled = false
    $0.tintColor = .disabledColor
    $0.setTitleTextAttributes(
      [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)],
      for: .normal
    )
  }
  
  let searchBar = UISearchBar(frame: .zero).then {
    $0.placeholder = "Type a restaurant name".localized
    $0.backgroundColor = .white
    $0.barTintColor = .white
    $0.tintColor = .tintColor
    $0.backgroundImage = UIImage()
    $0.showsCancelButton = true
  }
  
  let tableView = UITableView(frame: .zero).then {
    $0.register(Reusable.TitleCell)
    $0.backgroundColor = .white
    $0.contentInsetAdjustmentBehavior = .never
    $0.isHidden = true
  }
  
  let rating = CosmosView(frame: .zero).then {
    $0.rating = 0
    $0.settings.updateOnTouch = true
    $0.settings.fillMode = .precise
    $0.settings.filledColor = .tintColor
    $0.settings.emptyBorderColor = .tintColor
    $0.settings.filledBorderColor = .tintColor
    $0.settings.emptyBorderWidth = Metric.borderWidth
    $0.settings.starSize = Metric.starSize
  }
  
  let textView = UITextView(frame: .zero).then {
    $0.text = "Describe the taste".localized
    $0.textColor = .lightGray
    $0.font = UIFont.preferredFont(forTextStyle: .body)
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.autocorrectionType = .no
    $0.autocapitalizationType = .none
  }
  
  let indicator = UIActivityIndicatorView(style: .whiteLarge).then {
    $0.color = .tintColor
  }
  
  let indicatorView = UIView(frame: .zero).then {
    $0.backgroundColor = .black
    $0.alpha = Metric.indicatorAlpha
    $0.isHidden = true
  }
  
  // MARK: Initalize
  
  init(
    viewModel: PostViewModelType,
    photos: [PHAsset]
    ) {
    self.viewModel = viewModel
    self.locationManager = CLLocationManager()
    self.photos = photos
    super.init()
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Setup UI
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "POST".localized
    self.view.backgroundColor = .white
    
    self.navigationItem.rightBarButtonItem = self.writeButton
    self.view.addSubview(searchBar)
    self.view.addSubview(tableView)
    self.view.addSubview(rating)
    self.view.addSubview(textView)
    self.view.addSubview(indicatorView)
    self.view.addSubview(indicator)
    
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    locationManager.requestAlwaysAuthorization()
  }
  
  // MARK: Setup Constraints
  
  override func setupConstraints() {
    
    self.searchBar.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeArea.top)
      make.left.right.equalTo(self.view).inset(5)
    }
    
    self.tableView.snp.makeConstraints { make in
      make.left.right.equalTo(self.view)
      make.top.equalTo(self.searchBar.snp.bottom)
      make.bottom.equalTo(self.view.safeArea.bottom)
    }
    
    self.rating.snp.makeConstraints { make in
      make.top.equalTo(self.searchBar.snp.bottom).offset(Metric.offset)
      make.centerX.equalTo(self.view.snp.centerX)
    }
    
    self.textView.snp.makeConstraints { make in
      make.top.equalTo(self.rating.snp.bottom).offset(Metric.offset)
      make.left.right.equalTo(self.view).inset(Metric.offset)
      make.bottom.equalTo(self.view.safeArea.bottom)
    }
    
    self.indicator.snp.makeConstraints { make in
      make.center.equalTo(self.view.center)
    }
    
    self.indicatorView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
  }
  
  // MARK: - -> Rx Event Binding
  
  override func bindingEvent() {
    
    viewModel.inputs.photos(assets: self.photos)
    
    self.searchBar.rx.text
      .orEmpty
      .filter { !$0.isEmpty }
      .debounce(1.0, scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .bind(to: viewModel.inputs.query)
      .disposed(by: self.disposeBag)
    
    self.tableView.rx.modelSelected(Place.self)
      .bind(to: viewModel.inputs.didCellSelected)
      .disposed(by: self.disposeBag)
    
    self.textView.rx.text
      .orEmpty
      .distinctUntilChanged()
      .bind(to: viewModel.inputs.text)
      .disposed(by: self.disposeBag)
    
    self.writeButton.rx.tap
      .do(onNext: { [weak self] in
        self?.viewModel.inputs.rating.accept((self?.rating.rating)!)
      })
      .bind(to: viewModel.inputs.write)
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - <- Rx UI Binding
  
  override func bindingUI() {
    
    self.textView.rx.setDelegate(self)
      .disposed(by: self.disposeBag)
    
    self.searchBar.rx.setDelegate(self)
      .disposed(by: self.disposeBag)
    
    self.places.asObservable()
      .bind(to: self.tableView.rx.items(cellIdentifier: Reusable.TitleCell.identifier,
                                        cellType: UITableViewCell.self)) { row, element, cell in
                                          cell.textLabel?.text = element.name
      }.disposed(by: self.disposeBag)
    
    viewModel.outputs.places
      .subscribe(onNext: { [weak self] in
        self?.places($0)
      })
      .disposed(by: self.disposeBag)
    
    viewModel.outputs.selectedPlace
      .subscribe(onNext: { [weak self] in
        self?.selectedPlace($0)
      })
      .disposed(by: self.disposeBag)
    
    viewModel.outputs.writeIsEnabled
      .distinctUntilChanged()
      .drive(onNext: { [weak self] in
        self?.writeIsEnabled($0)
      })
      .disposed(by: self.disposeBag)
    
    viewModel.outputs.writed
      .drive(onNext: { [weak self] in
        self?.writed($0)
      })
      .disposed(by: self.disposeBag)
    
    viewModel.outputs.isNetworking
      .drive(onNext: { [weak self] isNetworking in
        self?.showNetworkingAnimation(isNetworking)
      })
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: Action Handler
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }
  
  private func places(_ result: NetworkResult<[Place]>) {
    switch result {
    case let .success(places):
      self.places.accept(places)
      
    case let .error(error):
      Toast(text: error.localizedDescription, duration: Delay.short).show()
    }
  }
  
  private func selectedPlace(_ place: Place) {
    self.restaurant = place
    self.searchBar.text = place.name
    self.searchBar.resignFirstResponder()
    self.tableView.isHidden.toggle()
    self.rating.isHidden.toggle()
    self.textView.isHidden.toggle()
  }
  
  private func writeIsEnabled(_ enabled: Bool) {
    self.writeButton.isEnabled = enabled
    if enabled {
      self.writeButton.tintColor = .tintColor
    } else {
      self.writeButton.tintColor = .disabledColor
    }
  }
  
  private func writed(_ isWrited: Bool) {
    if isWrited {
      self.navigationController?.popViewController(animated: true) {
        Toast(text: "Success Posting!".localized, duration: Delay.long).show()
      }
    } else {
      Toast(text: "Failure Posting!".localized, duration: Delay.long).show()
    }
  }
  
  private func showNetworkingAnimation(_ isNetworking: Bool) {
    if !isNetworking {
      self.indicator.stopAnimating()
      self.indicatorView.isHidden = true
    } else {
      self.indicator.startAnimating()
      self.indicatorView.isHidden = false
    }
  }
  
}

// MARK: UISearchBarDelegate

extension PostViewController: UISearchBarDelegate {
  
  func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    
    switch CLLocationManager.authorizationStatus() {
    case .authorizedAlways, .authorizedWhenInUse:
      locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
      locationManager.requestLocation()
      
      self.tableView.isHidden.toggle()
      self.rating.isHidden.toggle()
      self.textView.isHidden.toggle()
      
    default:
      let alertController = UIAlertController(
        title: "Current Location Not Available".localized,
        message: "Please allow this access in \n Settings > BlackBurger > Location".localized,
        preferredStyle: .alert
      )
      
      let settingsAction = UIAlertAction(title: "Settings".localized, style: .default) { _ in
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL, completionHandler: nil)
      }
      let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
      
      alertController.addAction(cancelAction)
      alertController.addAction(settingsAction)
      
      present(alertController, animated: true, completion: nil)
    }
    
    return true
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    self.tableView.isHidden.toggle()
    self.rating.isHidden.toggle()
    self.textView.isHidden.toggle()
  }
}

// MARK: -UITextViewDelegate

extension PostViewController: UITextViewDelegate {
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.textColor == .lightGray {
      textView.text = ""
      textView.textColor = .black
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = "Describe the taste".localized
      textView.textColor = .lightGray
    }
  }
}

// MARK: -CLLocationManagerDelegate

extension PostViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last{
      let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                          longitude: location.coordinate.longitude)
      self.viewModel.inputs.coordinate(coordinate: "\(center.longitude),\(center.latitude)")
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    Toast(text: error.localizedDescription, duration: Delay.long).show()
  }
}
