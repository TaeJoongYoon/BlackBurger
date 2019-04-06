//
//  PostListViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 30/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//


import ReusableKit
import RxCocoa
import RxSwift
import SnapKit
import Then
import TLPhotoPicker

final class PostListViewController: BaseViewController {
  
  // MARK: Constants
  
  struct Reusable {
    static let burgerPostCell = ReusableCell<BurgerPostCell>()
  }
  
  private struct Metric {
    static let baseMargin = CGFloat(20)
    static let tableViewFrame = UIScreen.main.bounds
    static let rowHeight = CGFloat(220)
  }
  
  // MARK: Properties
  
  var viewModel: PostListViewModelType!
  var posts = BehaviorRelay<[Post]>(value: [])
  var isMyList = true
  
  // MARK: UI
  
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
  
  let emptyLabel = UILabel(frame: .zero).then {
    $0.isHidden = true
  }
  
  // MARK: Setup UI
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.navigationItem.backBarButtonItem?.title = ""
    
    let backBarButtton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    self.navigationItem.backBarButtonItem = backBarButtton
    
    self.view.addSubview(self.tableView)
    self.view.addSubview(self.indicator)
    self.view.addSubview(self.emptyLabel)
  }
  
  // MARK: Setup Constraints
  
  override func setupConstraints() {
    
    self.tableView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeArea.top)
      make.left.right.equalToSuperview()
      make.bottom.equalTo(self.view.safeArea.bottom)
    }
    
    self.indicator.snp.makeConstraints { make in
      make.center.equalTo(self.view.center)
    }
    
    self.emptyLabel.snp.makeConstraints { make in
      make.center.equalTo(self.view.center)
    }
    
  }
  
  // MARK: - -> Rx Event Binding
  
  override func eventBinding() {
    
    self.rx.viewWillAppear
      .map { [weak self] in
        (self?.isMyList)!
      }
      .bind(to: viewModel.inputs.viewWillAppear)
      .disposed(by: self.disposeBag)
    
    self.tableView.rx.modelSelected(Post.self)
      .bind(to: viewModel.inputs.didCellSelected)
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: - <- Rx UI Binding
  
  override func uiBinding() {
    
    self.tableView.rx.setDelegate(self)
      .disposed(by: self.disposeBag)
    
    self.posts.asObservable()
      .bind(to: tableView.rx.items(cellIdentifier: Reusable.burgerPostCell.identifier,
                                   cellType: BurgerPostCell.self)) { row, element, cell in
                                    cell.configureWith(
                                      url: element.imageURLs[0],
                                      restaurant: element.restaurant,
                                      address: element.address,
                                      likes: element.likes,
                                      rating: element.rating
                                    )
                                    
      }.disposed(by: self.disposeBag)
    
    viewModel.outputs.posts
      .drive(onNext: { [weak self] in
        self?.setTableView($0)
      })
      .disposed(by: self.disposeBag)
    
    viewModel.outputs.showPost
      .drive(onNext: { [weak self] in
        self?.postDetail($0)
      })
      .disposed(by: self.disposeBag)
    
    viewModel.outputs.isNetworking
      .drive(onNext: { [weak self] isNetworking in
        self?.showNetworkingAnimation(isNetworking)
      }).disposed(by: self.disposeBag)
    
  }
  
  // MARK: Action Handler
  
  private func setTableView(_ posts: [Post]) {
    if self.isMyList {
      self.navigationItem.title = "My Posts".localized
    } else {
      self.navigationItem.title = "My Likes".localized
    }
    
    if posts.count > 0 {
      self.tableView.isHidden = false
      self.emptyLabel.isHidden = true
      self.posts.accept(posts)
    } else {
      self.tableView.isHidden = true
      self.emptyLabel.isHidden = false
      if self.isMyList {
        self.emptyLabel.text = "You don't have any posts".localized
      } else {
        self.emptyLabel.text = "You don't have any likes".localized
      }
    }
  }
  
  private func postDetail(_ post: Post) {
    let viewController = appDelegate.container.resolve(PostDetailViewController.self, argument: post)!
    self.navigationController?.pushViewController(viewController, animated: true)
  }
  
  private func showNetworkingAnimation(_ isNetworking: Bool) {
    if !isNetworking {
      self.indicator.stopAnimating()
    } else {
      self.indicator.startAnimating()
    }
  }
  
}

extension PostListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
