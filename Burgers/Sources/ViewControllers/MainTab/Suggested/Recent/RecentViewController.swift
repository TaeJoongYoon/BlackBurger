//
//  NewViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 02/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import ReusableKit
import RxCocoa
import RxSwift
import SnapKit
import Then
import TLPhotoPicker
import XLPagerTabStrip

final class RecentViewController: BaseViewController {
  
  // MARK: Constants
  
  fileprivate struct Reusable {
    static let burgerPostCell = ReusableCell<BurgerPostCell>()
  }
  
  fileprivate struct Metric {
    static let baseMargin = CGFloat(20)
    static let tableViewFrame = UIScreen.main.bounds
    static let rowHeight = CGFloat(220)
  }
  
  // MARK: Properties
  
  fileprivate let viewModel: RecentViewModelType
  fileprivate let presentPostDetailScreen: (Post) -> PostDetailViewController
  fileprivate let itemInfo = IndicatorInfo(title: "RECENT".localized)
  fileprivate let posts = BehaviorRelay<[Post]>(value: [])
  
  // MARK: UI
  
  let tableView = UITableView(frame: .zero, style: .plain).then {
    $0.backgroundColor = .white
    $0.contentInsetAdjustmentBehavior = .never
    $0.refreshControl = UIRefreshControl()
    $0.refreshControl?.tintColor = .tintColor
    $0.rowHeight = Metric.rowHeight
    $0.separatorInset = UIEdgeInsets.zero
    $0.register(Reusable.burgerPostCell)
  }
  
  let indicator = UIActivityIndicatorView(style: .whiteLarge).then {
    $0.color = .tintColor
  }
  
  let emptyLabel = UILabel(frame: .zero).then {
    $0.text = "No Posts".localized
    $0.isHidden = true
  }
  
  // MARK: Initalize
  
  init(
    viewModel: RecentViewModelType,
    presentPostDetailScreen: @escaping (Post) -> PostDetailViewController
    ) {
    self.viewModel = viewModel
    self.presentPostDetailScreen = presentPostDetailScreen
    super.init()
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Setup UI
  
  override func viewDidLoad() {
    super.viewDidLoad()
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
  
  override func bindingEvent() {
    
    self.rx.viewWillAppear
      .bind(to: viewModel.inputs.viewWillAppear)
      .disposed(by: self.disposeBag)
    
    self.tableView.refreshControl?.rx.controlEvent(.valueChanged)
      .bind(to: viewModel.inputs.didPulltoRefresh)
      .disposed(by: self.disposeBag)
    
    self.tableView.rx.modelSelected(Post.self)
      .bind(to: viewModel.inputs.didCellSelected)
      .disposed(by: self.disposeBag)
    
    self.tableView.rx.willDisplayCell
      .delay(1.0, scheduler: MainScheduler.instance)
      .map { [weak self] in
        $1.row + 1 == self?.posts.value.count
      }
      .filter { $0 }
      .distinctUntilChanged()
      .bind(to: viewModel.inputs.isReachedBottom)
      .disposed(by: disposeBag)
    
  }
  
  // MARK: - <- Rx UI Binding
  
  override func bindingUI() {
    
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
    
    viewModel.outputs.loadMore
      .drive(onNext: { [weak self] in
        self?.posts.accept((self?.posts.value)! + $0)
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
    if posts.count > 0 {
      self.tableView.isHidden = false
      self.emptyLabel.isHidden = true
      self.posts.accept(posts)
    } else {
      self.tableView.isHidden = true
      self.emptyLabel.isHidden = false
    }
  }
  
  private func postDetail(_ post: Post) {
    let viewController = self.presentPostDetailScreen(post)
    viewController.hidesBottomBarWhenPushed = true
    
    self.navigationController?.pushViewController(viewController, animated: true)
  }
  
  private func showNetworkingAnimation(_ isNetworking: Bool) {
    if !isNetworking {
      self.indicator.stopAnimating()
      self.tableView.refreshControl?.endRefreshing()
    } else if !tableView.refreshControl!.isRefreshing {
      self.indicator.startAnimating()
    }
  }
  
}


extension RecentViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension RecentViewController: IndicatorInfoProvider {
  func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return self.itemInfo
  }
}
