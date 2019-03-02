//
//  SuggestedViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 25/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import Kingfisher
import RxCocoa
import RxSwift
import Then

class SuggestedViewController: UIViewController, ViewType {
  
  // MARK: Constants
  
  struct Reusable {
    
  }
  
  struct Constant {
    
  }
  
  private struct Metric {
    static let segmentedBorderWidth = CGFloat(5.0)
  }
  
  // MARK: Rx
  
  var disposeBag: DisposeBag!
  
  // MARK: Properties
  
  var viewModel: SuggestedViewModelType!
  
  // MARK: UI
  
  let segmentedControl = UISegmentedControl(items: ["New", "Popular"]).then {
    $0.backgroundColor = .white
    $0.tintColor = .mainColor
    $0.layer.borderColor = UIColor.white.cgColor
    $0.layer.borderWidth = Metric.segmentedBorderWidth
    $0.selectedSegmentIndex = 0
  }
  
  let scrollView = UIScrollView(frame: .zero).then {
    $0.isPagingEnabled = true
    $0.isDirectionalLockEnabled = true
    $0.backgroundColor = .white
  }
  
  let newView = NewViewController.create(with: NewViewModel())
  
  let top20View = Top20ViewController.create(with: Top20ViewModel())
  
  // MARK: Setup UI
  
  func setupUI() {
    self.title = "Suggested"
    self.view.backgroundColor = .white
    self.view.addSubview(self.segmentedControl)
    
    self.scrollView.addSubview(self.newView.view)
    self.scrollView.addSubview(self.top20View.view)
    
    self.scrollView.contentSize = CGSize(width: self.view.bounds.width * 2, height: self.scrollView.bounds.height)
    self.view.addSubview(self.scrollView)
  }
  
  // MARK: Setup Constraints
  
  func setupConstraints() {
    
    self.segmentedControl.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeArea.top)
      make.left.right.equalTo(self.view)
      make.width.equalTo(self.view)
      make.height.equalTo(45)
    }
    
    self.scrollView.snp.makeConstraints { make in
      make.top.equalTo(self.segmentedControl.snp.bottom)
      make.left.right.equalTo(self.view)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
    }
    
    self.newView.view.snp.makeConstraints { make in
      make.width.equalTo(self.view.frame.width)
      make.height.equalTo(self.view.frame.height)
      make.top.left.bottom.equalTo(self.scrollView)
      make.right.equalTo(self.top20View.view.snp.left)
    }
    
    self.top20View.view.snp.makeConstraints { make in
      make.width.equalTo(self.view.frame.width)
      make.height.equalTo(self.view.frame.height)
      make.top.bottom.right.equalTo(self.scrollView)
      make.left.equalTo(self.newView.view.snp.right)
    }
    
  }
  
  // MARK: - -> Rx Event Binding
  
  func setupEventBinding() {
    
    rx.viewWillAppear.bind(to: viewModel.willAppear).disposed(by: disposeBag)
    
    self.segmentedControl.rx.selectedSegmentIndex
      .bind(to: viewModel.selectedSegmentIndex)
      .disposed(by: disposeBag)
    
    self.scrollView.rx.contentOffset
      .map { [weak self] in
        Int($0.x / (self?.view.bounds.width)!)
      }
      .distinctUntilChanged()
      .bind(to: viewModel.swipePage)
      .disposed(by: disposeBag)
  }
  
  // MARK: - <- Rx UI Binding
  
  func setupUIBinding() {
    
    viewModel.showView
      .drive(onNext: { [weak self] index in
        let width = (self?.view.bounds.width)! * CGFloat(index)
        
        self?.scrollView.setContentOffset(CGPoint(x: width, y: 0), animated: true)
        self?.segmentedControl.selectedSegmentIndex = index
      })
      .disposed(by: disposeBag)
    
    viewModel.s.drive(onNext: {
      print($0)
    }).disposed(by: disposeBag)
  }
  
}
