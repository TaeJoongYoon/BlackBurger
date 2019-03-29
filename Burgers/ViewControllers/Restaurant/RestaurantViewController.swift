//
//  RestaurantViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 24/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import ReusableKit
import RxCocoa
import RxGesture
import RxSwift
import Then

final class RestaurantViewController: BaseViewController, ViewType {
  
  // MARK: Constants
  
  struct Reusable {
    static let burgerPostCell = ReusableCell<SimplePostCell>()
  }
  
  struct Metric {
    static let rowHeight = CGFloat(130)
    static let nameFontSize = CGFloat(20)
    static let addressFontSize = CGFloat(14)
    static let borderWidth = CGFloat(1)
    static let contentHeight = CGFloat(180)
    static let offset = 20
  }
  
  // MARK: Properties
  
  var viewModel: RestaurantViewModelType!
  var posts = BehaviorRelay<[Post]>(value: [])
  var restaurant: [AnyHashable: Any]!
  //  "name": name
  //  "address": jibunAddress
  //  "phone_number": phoneNumber
  //  "lat": lat
  //  "lng": lng
  //  "distance": distance
  
  // MARK: UI
  
  let contentView = UIView(frame: .zero)
  
  let nameLabel = UILabel(frame: .zero).then {
    $0.font = UIFont.boldSystemFont(ofSize: Metric.nameFontSize)
  }
  
  let addressLabel = UILabel(frame: .zero).then {
    $0.font = $0.font.withSize(Metric.addressFontSize)
    $0.textColor = .disabledColor
  }
  
  let phoneLabel = UILabel(frame: .zero).then {
    $0.font = $0.font.withSize(14)
    $0.textColor = .disabledColor
    $0.isUserInteractionEnabled = true
  }
  
  let tableView = UITableView(frame: .zero, style: .plain).then {
    $0.backgroundColor = .white
    $0.contentInsetAdjustmentBehavior = .never
    $0.refreshControl = nil
    $0.rowHeight = Metric.rowHeight
    $0.separatorInset = UIEdgeInsets.zero
    $0.register(Reusable.burgerPostCell)
  }
  
  let indicator = UIActivityIndicatorView(style: .whiteLarge).then {
    $0.color = .tintColor
  }
  
  // MARK: Setup UI
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = "RESTAURANT".localized
    self.view.backgroundColor = .white
    let backBarButtton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    self.navigationItem.backBarButtonItem = backBarButtton
    
    self.contentView.addSubview(nameLabel)
    self.contentView.addSubview(addressLabel)
    self.contentView.addSubview(phoneLabel)
    
    self.view.addSubview(contentView)
    self.view.addSubview(tableView)
    self.view.addSubview(indicator)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.nameLabel.text = self.restaurant["name"] as? String
    self.addressLabel.text = self.restaurant["address"] as? String
    self.phoneLabel.text = self.restaurant["phone_number"] as? String
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    self.contentView.layer.addBorder([.bottom], color: .black, width: Metric.borderWidth)
  }
  
  // MARK: Setup Constraints
  
  override func setupConstraints() {
    
    self.contentView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeArea.top)
      make.left.right.equalToSuperview()
      make.height.equalTo(Metric.contentHeight)
    }
    
    self.nameLabel.snp.makeConstraints { make in
      make.top.equalTo(self.contentView).offset(Metric.offset)
      make.left.equalTo(self.contentView).offset(Metric.offset)
    }
    
    self.addressLabel.snp.makeConstraints { make in
      make.top.equalTo(self.nameLabel.snp.bottom).offset(Metric.offset)
      make.left.equalTo(self.contentView).offset(Metric.offset)
    }
    
    self.phoneLabel.snp.makeConstraints { make in
      make.top.equalTo(self.addressLabel.snp.bottom).offset(Metric.offset)
      make.left.equalTo(self.contentView).offset(Metric.offset)
    }
    
    self.tableView.snp.makeConstraints { make in
      make.top.equalTo(self.contentView.snp.bottom)
      make.left.right.equalToSuperview()
      make.bottom.equalTo(self.view.safeArea.bottom)
    }
    
    self.indicator.snp.makeConstraints { make in
      make.center.equalTo(self.view.center)
    }
    
  }
  
  // MARK: - -> Rx Event Binding
  
  func setupEventBinding() {
    
    self.rx.viewWillAppear
      .map { [weak self] in
        self?.restaurant["name"] as! String
        
      }
      .bind(to: viewModel.viewWillAppear)
      .disposed(by: self.disposeBag)

    self.tableView.rx.modelSelected(Post.self)
      .bind(to: viewModel.didCellSelected)
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: - <- Rx UI Binding
  
  func setupUIBinding() {
    
    self.tableView.rx.setDelegate(self)
      .disposed(by: self.disposeBag)
    
    self.posts.asObservable()
      .bind(to: tableView.rx.items(cellIdentifier: Reusable.burgerPostCell.identifier,
                                   cellType: SimplePostCell.self)) { row, element, cell in
                                    cell.configureWith(
                                      url: element.imageURLs[0],
                                      content: element.content,
                                      rating: element.rating,
                                      likes: element.likes
                                    )
                                    
      }
      .disposed(by: self.disposeBag)
    
    self.phoneLabel.rx
      .tapGesture()
      .when(.recognized)
      .subscribe(onNext: { [weak self] _ in
        self?.call()
      })
      .disposed(by: self.disposeBag)
    
    viewModel.posts
      .drive(onNext: { [weak self] in
        self?.posts.accept($0)
      })
      .disposed(by: self.disposeBag)
    
    viewModel.showPost
      .drive(onNext: { [weak self] in
        self?.postDetail($0)
      })
      .disposed(by: self.disposeBag)
    
    viewModel.isNetworking
      .drive(onNext: { [weak self] isNetworking in
        self?.showNetworkingAnimation(isNetworking)
      })
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: Action Handler
  
  private func postDetail(_ post: Post) {
    let viewModel = PostDetailViewModel()
    let viewController = PostDetailViewController.create(with: viewModel)
    viewController.post = post
    viewController.hidesBottomBarWhenPushed = true
    
    self.navigationController?.pushViewController(viewController, animated: true)
  }
  
  private func call() {
    if let url = URL(string: "tel://\(self.phoneLabel.text!)"),
      UIApplication.shared.canOpenURL(url) {
      if #available(iOS 10, *) {
        UIApplication.shared.open(url)
      } else {
        UIApplication.shared.openURL(url)
      }
    }
  }
  
  private func showNetworkingAnimation(_ isNetworking: Bool) {
    if !isNetworking {
      self.indicator.stopAnimating()
    } else {
      self.indicator.startAnimating()
    }
  }
  
}

extension RestaurantViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
