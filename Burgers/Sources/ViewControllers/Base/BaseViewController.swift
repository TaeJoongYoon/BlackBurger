//
//  BaseViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 24/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//


import UIKit

import RxSwift

class BaseViewController: UIViewController {
  
  // MARK: Properties
  lazy private(set) var className: String = {
    return type(of: self).description().components(separatedBy: ".").last ?? ""
  }()
  
  var appDelegate: AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
  }
  
  var automaticallyAdjustsLeftBarButtonItem = true
  
  /// There is a bug when trying to go back to previous view controller in a navigation controller
  /// on iOS 11, a scroll view in the previous screen scrolls weirdly. In order to get this fixed,
  /// we have to set the scrollView's `contentInsetAdjustmentBehavior` property to `.never` on
  /// `viewWillAppear()` and set back to the original value on `viewDidAppear()`.
  private var scrollViewOriginalContentInsetAdjustmentBehaviorRawValue: Int?
  
  
  // MARK: Initializing
  init() {
    super.init(nibName: nil, bundle: nil)
    log.verbose("INIT: \(self.className)")
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    self.init()
  }
  
  deinit {
    log.verbose("DEINIT: \(self.className)")
  }
  
  
  // MARK: Rx
  var disposeBag = DisposeBag()
  
  // MARK: View Lifecycle
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if self.automaticallyAdjustsLeftBarButtonItem {
      self.adjustLeftBarButtonItem()
    }
    
    // fix iOS 11 scroll view bug
    if #available(iOS 11, *) {
      if let scrollView = self.view.subviews.first as? UIScrollView {
        self.scrollViewOriginalContentInsetAdjustmentBehaviorRawValue =
          scrollView.contentInsetAdjustmentBehavior.rawValue
        scrollView.contentInsetAdjustmentBehavior = .never
      }
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    // fix iOS 11 scroll view bug
    if #available(iOS 11, *) {
      if let scrollView = self.view.subviews.first as? UIScrollView,
        let rawValue = self.scrollViewOriginalContentInsetAdjustmentBehaviorRawValue,
        let behavior = UIScrollView.ContentInsetAdjustmentBehavior(rawValue: rawValue) {
        scrollView.contentInsetAdjustmentBehavior = behavior
      }
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
  }
  
  // MARK: Layout Constraints
  private(set) var didSetupConstraints = false
  
  override func viewDidLoad() {
    self.view.setNeedsUpdateConstraints()
    self.eventBinding()
    self.uiBinding()
  }
  
  override func updateViewConstraints() {
    if !self.didSetupConstraints {
      self.setupConstraints()
      self.didSetupConstraints = true
    }
    super.updateViewConstraints()
  }
  
  func setupConstraints() {
    // Override point
  }
  
  // MARK: Data Binding
  
  func eventBinding() {
    // Override point
  }
  
  func uiBinding() {
    // Override point
  }
  
  // MARK: Adjusting Navigation Item
  func adjustLeftBarButtonItem() {
    if self.navigationController?.viewControllers.count ?? 0 > 1 { // pushed
      self.navigationItem.leftBarButtonItem = nil
    } else if self.presentingViewController != nil { // presented
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .cancel,
        target: self,
        action: #selector(cancelButtonDidTap)
      )
    }
  }
  
  @objc func cancelButtonDidTap() {
    self.dismiss(animated: true, completion: nil)
  }
  
}
