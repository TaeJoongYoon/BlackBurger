//
//  UIScrollView+IsReachedBottom.swift
//  Burgers
//
//  Created by Tae joong Yoon on 04/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

extension UIScrollView {
  var isOverflowVertical: Bool {
    return self.contentSize.height > self.frame.height && self.frame.height > 0
  }
  
  func isReachedBottom(withTolerance tolerance: CGFloat = 0) -> Bool {
    guard self.isOverflowVertical else { return false }
    let contentOffsetBottom = self.contentOffset.y + self.frame.height
    return contentOffsetBottom >= self.contentSize.height - tolerance
  }
}

extension Reactive where Base: UIScrollView {
  
  var isReachedBottom: ControlEvent<Void> {
    let source = self.contentOffset
      .filter { [weak base = self.base] offset in
        guard let base = base else { return false }
        return base.isReachedBottom(withTolerance: base.frame.height / 2)
      }
      .map { _ in Void() }
    return ControlEvent(events: source)
  }
  
}
