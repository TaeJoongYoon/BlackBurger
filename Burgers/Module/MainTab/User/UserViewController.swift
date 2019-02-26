//
//  UserViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 25/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

class UserViewController: UIViewController, ViewType {
  
  // MARK: Constants
  
  struct Reusable {
    
  }
  
  struct Constant {
    
  }
  
  struct Metric {
    
  }
  
  // MARK: Rx
  
  var disposeBag: DisposeBag!
  
  // MARK: Properties
  
  var viewModel: UserViewModelType!
  
  // MARK: Setup UI
  
  func setupUI() {
    self.title = "User"
    self.view.backgroundColor = .white
  }
  
  // MARK: Setup Constraints
  
  func setupConstraints() {
    
  }
  
  // MARK: - -> Rx Event Binding
  
  func setupEventBinding() {
    
  }
  
  // MARK: - <- Rx UI Binding
  
  func setupUIBinding() {
    
  }
}
