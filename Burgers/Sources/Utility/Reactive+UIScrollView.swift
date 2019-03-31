//
//  Reactive+UIScrollView.swift
//  Burgers
//
//  Created by Tae joong Yoon on 01/04/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

extension Reactive where Base: UIScrollView {
  var currentPage: Observable<Int> {
    return didEndDecelerating.map({
      let pageWidth = self.base.frame.width
      let page = floor((self.base.contentOffset.x - pageWidth / 2) / pageWidth) + 1
      return Int(page)
    })
  }
}
