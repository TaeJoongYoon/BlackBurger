//
//  Reactive+UIViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 02/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxCocoa
import RxSwift

extension Reactive where Base: UIViewController {
  var viewDidLoad: ControlEvent<Void> {
    let source = methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
    return ControlEvent(events: source)
  }
  
  var viewWillAppear: ControlEvent<Void> {    
    let source = methodInvoked(#selector(Base.viewWillAppear)).map { _ in }
    return ControlEvent(events: source)
  }
  
  var viewDidAppear: ControlEvent<Void> {
    let source = methodInvoked(#selector(Base.viewDidAppear(_:))).map { _ in }
    return ControlEvent(events: source)
  }
  
  var viewWillDisappear: ControlEvent<Void> {
    let source = methodInvoked(#selector(Base.viewWillDisappear(_:))).map { _ in }
    return ControlEvent(events: source)
  }
  
  var viewDisDisappear: ControlEvent<Void> {
    let source = methodInvoked(#selector(Base.viewDidDisappear(_:))).map { _ in }
    return ControlEvent(events: source)
  }
}
