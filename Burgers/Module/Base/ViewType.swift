//
//  ViewType.swift
//  Burgers
//
//  Created by Tae joong Yoon on 25/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import UIKit
import RxSwift

protocol ViewType: class {
  associatedtype ViewModelType
  var viewModel: ViewModelType! { get set }
  var disposeBag: DisposeBag! { get set }
  
  func setupUI()
  func setupConstraints()
  func setupEventBinding()
  func setupUIBinding()
}

extension ViewType where Self: UIViewController {
  static func create(with viewModel: ViewModelType) -> Self {
    let `self` = Self()
    self.viewModel = viewModel
    self.disposeBag = DisposeBag()
    self.loadViewIfNeeded()
    self.setupUI()
    self.setupConstraints()
    self.setupEventBinding()
    self.setupUIBinding()
    return self
  }
}
