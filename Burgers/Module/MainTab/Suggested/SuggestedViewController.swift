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
  
  let v1 = UIView(frame: .zero).then {
    $0.backgroundColor = .red
  }
  
  let v2 = UIView(frame: .zero).then {
    $0.backgroundColor = .blue
  }
  
  let segmentedControl = UISegmentedControl(items: ["New", "Popular"]).then {
    $0.backgroundColor = .white
    $0.tintColor = .orange
    $0.layer.borderColor = UIColor.white.cgColor
    $0.layer.borderWidth = Metric.segmentedBorderWidth
    $0.selectedSegmentIndex = 0
  }
  
  let scrollView = UIScrollView(frame: .zero).then {
    $0.isPagingEnabled = true
    $0.isDirectionalLockEnabled = true
    $0.backgroundColor = .white
  }
  
  // MARK: Setup UI
  
  func setupUI() {
    self.title = "Suggested"
    self.view.backgroundColor = .white
    self.view.addSubview(self.segmentedControl)
    
    self.v1.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: view.frame.height)
    self.scrollView.addSubview(self.v1)
    
    self.v2.frame = CGRect(x: self.view.frame.width, y: 0, width: self.view.frame.width, height: view.frame.height)
    self.scrollView.addSubview(self.v2)
    
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
    
  }
  
  // MARK: - -> Rx Event Binding
  
  func setupEventBinding() {
    
    self.segmentedControl.rx.selectedSegmentIndex
      .bind(to: viewModel.selectedSegmentIndex)
      .disposed(by: disposeBag)
    
    self.scrollView.rx.setDelegate(self).disposed(by: disposeBag)
    
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
  }
  
}

extension SuggestedViewController: UIScrollViewDelegate {
  
}
