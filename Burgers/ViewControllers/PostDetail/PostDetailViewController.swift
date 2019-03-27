//
//  PostDetailViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 24/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

final class PostDetailViewController: BaseViewController, ViewType {
  
  // MARK: Constants
  
  struct Reusable {
    
  }
  
  struct Constant {
    
  }
  
  struct Metric {
    
  }
  
  // MARK: Properties
  
  var viewModel: PostDetailViewModelType!
  var post: Post!
  
  // MARK: UI
  
  let moreButton = UIBarButtonItem().then {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "more.png"), for: .normal)
    $0.customView = button
  }

  
  // MARK: Setup UI
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "DETAIL".localized
    self.view.backgroundColor = .white
    
    self.navigationItem.rightBarButtonItem = self.moreButton
  }
  
  // MARK: Setup Constraints
  
  override func setupConstraints() {
    
  }
  
  // MARK: - -> Rx Event Binding
  
  func setupEventBinding() {
    
  }
  
  // MARK: - <- Rx UI Binding
  
  func setupUIBinding() {
    
  }
  
}
