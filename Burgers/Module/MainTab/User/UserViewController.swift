//
//  UserViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 25/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

final class UserViewController: UIViewController, ViewType {
  
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
  
  // MARK: UI
  
  
  
  // MARK: Setup UI
  
  func setupUI() {
    self.navigationItem.title = "USER".localized
    self.view.backgroundColor = .white
    self.tabBarItem.image = UIImage(named: "user-unselected.png")
    self.tabBarItem.selectedImage = UIImage(named: "user-selected.png")
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
