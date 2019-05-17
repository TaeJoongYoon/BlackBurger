//
//  TermsViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 30/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import UIKit
import WebKit

import SnapKit

final class TermsViewController: BaseViewController, WKUIDelegate {
  
  fileprivate var webView: WKWebView!
  fileprivate let isTerms: Bool
  
  // MARK: Initalize
  
  init(
    isTerms: Bool
    ) {
    self.isTerms = isTerms
    super.init()
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    
    let webConfiguration = WKWebViewConfiguration()
    webView = WKWebView(frame: .zero, configuration: webConfiguration)
    webView.uiDelegate = self
    
    self.view.addSubview(self.webView)
    
    let string = isTerms ? "Burgers+Terms" : "Burgers+Privacy"
    guard let path = Bundle.main.path(forResource: string, ofType: "html") else {
      log.error("path is nil")
      return
    }
    
    let url = URL(fileURLWithPath: path)
    let request = URLRequest(url: url)
    
    webView.load(request)
  }
  
  override func setupConstraints() {
    self.webView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeArea.top)
      make.left.right.equalToSuperview()
      make.bottom.equalTo(self.view.safeArea.bottom)
    }
  }
  
}

