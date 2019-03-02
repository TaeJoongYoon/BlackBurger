//
//  NewViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 02/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import ReusableKit
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit
import Then

class NewViewController: UIViewController, ViewType {
  
  // MARK: Constants
  
  struct Reusable {
    static let suggestedCell = ReusableCell<SuggestedTableViewCell>()
  }
  
  struct Constant {
    
  }
  
  private struct Metric {
    static let baseMargin = CGFloat(8)
    static let tableViewFrame = UIScreen.main.bounds
    static let rowHeight = CGFloat(250)
  }
  
  // MARK: Rx
  
  var disposeBag: DisposeBag!
  
  // MARK: Properties
  
  var viewModel: NewViewModelType!
  
  // MARK: UI
  
  let tableView = UITableView(frame: .zero, style: .plain).then {
    $0.refreshControl = UIRefreshControl()
    $0.refreshControl?.tintColor = .mainColor
    $0.rowHeight = Metric.rowHeight
    $0.separatorInset = UIEdgeInsets(top: Metric.baseMargin, left: Metric.baseMargin, bottom: Metric.baseMargin, right: Metric.baseMargin)
    $0.register(Reusable.suggestedCell)
  }
  
  let indicator = UIActivityIndicatorView(style: .whiteLarge).then {
    $0.color = .mainColor
  }
  
  // MARK: Setup UI
  
  func setupUI() {
    self.view.addSubview(self.tableView)
    self.view.addSubview(self.indicator)
  }
  
  // MARK: Setup Constraints
  
  func setupConstraints() {
    
    self.tableView.snp.makeConstraints { make in
      make.edges.equalTo(self.view)
    }
    
    self.indicator.snp.makeConstraints { make in
      make.center.equalTo(self.view.center)
    }
  }
  
  // MARK: - -> Rx Event Binding
  
  func setupEventBinding() {
    rx.viewWillAppear
      .bind(to: viewModel.viewWillAppear)
      .disposed(by: disposeBag)
    
    tableView.refreshControl?.rx.controlEvent(.valueChanged)
      .bind(to: viewModel.didPulltoRefresh)
      .disposed(by: disposeBag)
    
    tableView.rx.modelSelected(PostsData.Item.self)
      .bind(to: viewModel.didCellSelected)
      .disposed(by: disposeBag)
  }
  
  // MARK: - <- Rx UI Binding
  
  func setupUIBinding() {
    let dataSource = RxTableViewSectionedReloadDataSource<PostsData>(
      configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
        let cell = tableView.dequeue(Reusable.suggestedCell)!
        
        cell.configureWith()
        return cell
    })
    
    viewModel.posts
      .drive(tableView.rx.items(dataSource: dataSource))
      .dispose()
    
    viewModel.showPost
      .drive(onNext: {
        print($0)
      })
      .disposed(by: disposeBag)
    
  }
  
}
