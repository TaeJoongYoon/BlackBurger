//
//  SuggestedViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 25/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

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
    static let segmentedBorderWidth = CGFloat(1.0)
  }
  
  // MARK: Rx
  
  var disposeBag: DisposeBag!
  
  // MARK: Properties
  
  var viewModel: SuggestedViewModelType!
  
  // MARK: UI
  
  let segmentedControl = UISegmentedControl(items: ["New", "Popular"]).then {
    $0.backgroundColor = .white
    $0.tintColor = .orange
    $0.layer.borderColor = UIColor.white.cgColor
    $0.layer.borderWidth = Metric.segmentedBorderWidth
    $0.selectedSegmentIndex = 0
  }
  
  // MARK: Setup UI
  
  func setupUI() {
    self.title = "Suggested"
    self.view.backgroundColor = .white
    self.view.addSubview(self.segmentedControl)
  }
  
  // MARK: Setup Constraints
  
  func setupConstraints() {
    
    self.segmentedControl.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeArea.top)
      make.left.right.equalTo(self.view)
      make.width.equalTo(self.view)
      make.height.equalTo(45)
    }
    
    
  }
  
  // MARK: - -> Rx Event Binding
  
  func setupEventBinding() {
    
    self.segmentedControl.rx.selectedSegmentIndex
      .bind(to: viewModel.selectedSegmentIndex)
      .disposed(by: disposeBag)
    
  }
  
  // MARK: - <- Rx UI Binding
  
  func setupUIBinding() {
    viewModel.showView
      .drive(onNext: { index in
        print(index)
      })
      .disposed(by: disposeBag)
  }
  
}
