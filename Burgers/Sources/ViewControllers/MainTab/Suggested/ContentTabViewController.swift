//
//  ContentTabView.swift
//  Burgers
//
//  Created by Tae joong Yoon on 30/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import XLPagerTabStrip

class ContentTabViewController: ButtonBarPagerTabStripViewController {
  
  // MARK: Properties
  lazy private(set) var className: String = {
    return type(of: self).description().components(separatedBy: ".").last ?? ""
  }()
  
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
  
  // MARK: View Lifecycle
  
  override func viewDidLoad() {
    
    settings.style.buttonBarBackgroundColor = .white
    settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 14)
    settings.style.buttonBarHeight = 34.0
    settings.style.buttonBarItemTitleColor = .tintColor
    settings.style.buttonBarItemBackgroundColor = .white
    settings.style.selectedBarHeight = 2.0
    settings.style.selectedBarBackgroundColor = .tintColor
    
    super.viewDidLoad()
  }
  
  // MARK: TabViewControllers
  
  override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
    
    let recentView = RecentViewController.create(with: RecentViewModel())
    let popularView = PopularViewController.create(with: PopularViewModel())
    
    return [recentView, popularView]
  }
  
}
