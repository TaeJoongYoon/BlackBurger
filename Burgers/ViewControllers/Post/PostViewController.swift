//
//  PostViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 24/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import CoreLocation

import Alamofire
import Cosmos
import ReusableKit
import RxCocoa
import RxSwift
import Then
import Toaster

final class PostViewController: BaseViewController, ViewType {
  
  // MARK: Constants
  
  struct Reusable {
    static let TitleCell = ReusableCell<UITableViewCell>()
  }
  
  struct Constant {
    
  }
  
  struct Metric {
    static let borderWidth = Double(2)
    static let offset = CGFloat(20)
  }
  
  // MARK: Properties
  
  var viewModel: PostViewModelType!
  let locationManager = CLLocationManager()
  let coordinate = BehaviorRelay<String>(value: "")
  
  // MARK: UI
  
  let writeButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: nil).then {
    $0.isEnabled = false
    $0.tintColor = .disabledColor
  }
  
  let searchBar = UISearchBar(frame: .zero).then {
    $0.placeholder = "Type a restaurant name".localized
    $0.backgroundColor = .white
    $0.barTintColor = .white
    $0.tintColor = .tintColor
    $0.backgroundImage = UIImage()
    $0.showsCancelButton = true
    //$0.setShowsCancelButton(true, animated: true)
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
    $0.alpha = 0.5
    $0.isHidden = true
  }
  
  // MARK: Setup UI
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "POST".localized
    self.view.backgroundColor = .white
    
    self.rating.settings.starSize = Double(UIScreen.main.bounds.size.width / 8)
    
    self.navigationItem.rightBarButtonItem = self.writeButton
    self.view.addSubview(searchBar)
    self.view.addSubview(tableView)
    self.view.addSubview(rating)
    self.view.addSubview(textView)
    self.view.addSubview(indicatorView)
    self.view.addSubview(indicator)
    
    locationManager.requestWhenInUseAuthorization()
    
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
      locationManager.startUpdatingLocation()
    }
    
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
      make.top.equalTo(self.view.safeArea.top)
      make.left.right.equalTo(self.view)
      make.bottom.equalTo(self.view.safeArea.bottom)
    }
    
  }
  
  // MARK: - -> Rx Event Binding
  
  func setupEventBinding() {
    
    self.textView.rx.setDelegate(self)
      .disposed(by: self.disposeBag)
    
    self.searchBar.rx.setDelegate(self)
      .disposed(by: self.disposeBag)
    
    self.coordinate
      .bind(to: viewModel.coordinate)
      .disposed(by: self.disposeBag)
    
    self.searchBar.rx.text
      .orEmpty
      .filter { !$0.isEmpty }
      .debounce(1.0, scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .bind(to: viewModel.query)
      .disposed(by: self.disposeBag)
    
    self.tableView.rx.modelSelected(Place.self)
      .bind(to: viewModel.didCellSelected)
      .disposed(by: self.disposeBag)
    
    self.textView.rx.text
      .orEmpty
      .distinctUntilChanged()
      .bind(to: viewModel.text)
      .disposed(by: self.disposeBag)
    
    self.writeButton.rx.tap
      .do(onNext: { [weak self] in
        self?.viewModel.rating.accept((self?.rating.rating)!)
      })
      .bind(to: viewModel.write)
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - <- Rx UI Binding
  
  func setupUIBinding() {
    
    viewModel.places
      .asObservable()
      .bind(to: self.tableView.rx.items(cellIdentifier: Reusable.TitleCell.identifier,
                                        cellType: UITableViewCell.self)) { row, element, cell in
                                         cell.textLabel?.text = element.name
    }.disposed(by: self.disposeBag)
    
    viewModel.selectedPlace
      .drive(onNext: { [weak self] in
        self?.searchBar.text = $0
        self?.searchBar.resignFirstResponder()
        self?.tableView.isHidden.toggle()
        self?.rating.isHidden.toggle()
        self?.textView.isHidden.toggle()
      })
      .disposed(by: self.disposeBag)
    
    viewModel.writeisEnabled
      .distinctUntilChanged()
      .drive(onNext: { [weak self] in
        self?.writeButton.isEnabled = $0
        if $0 {
          self?.writeButton.tintColor = .tintColor
        } else {
          self?.writeButton.tintColor = .disabledColor
        }
      })
      .disposed(by: self.disposeBag)
    
    viewModel.writed
      .drive(onNext: { [weak self] in
        if $0 {
          self?.navigationController?.popViewController(animated: true) {
            Toast(text: "Success Posting!".localized, duration: Delay.long).show()
          }
        } else {
          Toast(text: "Failure Posting!".localized, duration: Delay.long).show()
        }
      })
      .disposed(by: self.disposeBag)
    
    viewModel.isNetworking
      .drive(onNext: { [weak self] isNetworking in
        self?.showNetworkingAnimation(isNetworking)
      })
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: Action Handler
  
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

extension PostViewController: UISearchBarDelegate {
  func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    self.tableView.isHidden.toggle()
    self.rating.isHidden.toggle()
    self.textView.isHidden.toggle()
    return true
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    self.tableView.isHidden.toggle()
    self.rating.isHidden.toggle()
    self.textView.isHidden.toggle()
  }
}

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

extension PostViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last{
      let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
      
      self.coordinate.accept("\(center.longitude),\(center.latitude)")
      self.locationManager.stopUpdatingLocation()
    }
  }
}
