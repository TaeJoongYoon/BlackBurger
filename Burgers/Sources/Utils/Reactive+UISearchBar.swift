//
//  Reactive+UISearchBar.swift
//  Burgers
//
//  Created by Tae joong Yoon on 27/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

extension Reactive where Base: UISearchBar {
  public func setDelegate(_ delegate: UISearchBarDelegate)
    -> Disposable {
      return RxSearchBarDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
  }
}
