//
//  Window+SetRootView.swift
//  Burgers
//
//  Created by Tae joong Yoon on 07/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import Foundation
import UIKit

public extension UIWindow {
  
  /// Transition Options
  public struct TransitionOptions {
    
    /// Curve of animation
    ///
    /// - linear: linear
    /// - easeIn: ease in
    /// - easeOut: ease out
    /// - easeInOut: ease in - ease out
    public enum Curve {
      case linear
      case easeIn
      case easeOut
      case easeInOut
      
      /// Return the media timing function associated with curve
      internal var function: CAMediaTimingFunction {
        let name: CAMediaTimingFunctionName
        switch self {
        case .linear:    name = CAMediaTimingFunctionName.linear
        case .easeIn:    name = CAMediaTimingFunctionName.easeIn
        case .easeOut:    name = CAMediaTimingFunctionName.easeOut
        case .easeInOut:  name = CAMediaTimingFunctionName.easeInEaseOut
        }
        return CAMediaTimingFunction(name: name)
      }
    }
    
    /// Direction of the animation
    ///
    /// - fade: fade to new controller
    /// - toTop: slide from bottom to top
    /// - toBottom: slide from top to bottom
    /// - toLeft: pop to left
    /// - toRight: push to right
    public enum Direction {
      case fade
      case toTop
      case toBottom
      case toLeft
      case toRight
      
      /// Return the associated transition
      ///
      /// - Returns: transition
      internal func transition() -> CATransition {
        let transition = CATransition()
        transition.type = CATransitionType.push
        switch self {
        case .fade:
          transition.type = CATransitionType.fade
          transition.subtype = nil
        case .toLeft:
          transition.subtype = CATransitionSubtype.fromLeft
        case .toRight:
          transition.subtype = CATransitionSubtype.fromRight
        case .toTop:
          transition.subtype = CATransitionSubtype.fromTop
        case .toBottom:
          transition.subtype = CATransitionSubtype.fromBottom
        }
        return transition
      }
    }
    
    /// Background of the transition
    ///
    /// - solidColor: solid color
    /// - customView: custom view
    public enum Background {
      case solidColor(_: UIColor)
      case customView(_: UIView)
    }
    
    /// Duration of the animation (default is 0.80s)
    public var duration: TimeInterval = 0.8
    
    /// Direction of the transition (default is `toRight`)
    public var direction: TransitionOptions.Direction = .toRight
    
    /// Style of the transition (default is `linear`)
    public var style: TransitionOptions.Curve = .linear
    
    /// Background of the transition (default is `nil`)
    public var background: TransitionOptions.Background? = nil
    
    /// Initialize a new options object with given direction and curve
    ///
    /// - Parameters:
    ///   - direction: direction
    ///   - style: style
    public init(direction: TransitionOptions.Direction = .toRight, style: TransitionOptions.Curve = .linear) {
      self.direction = direction
      self.style = style
    }
    
    public init() { }
    
    /// Return the animation to perform for given options object
    internal var animation: CATransition {
      let transition = self.direction.transition()
      transition.duration = self.duration
      transition.timingFunction = self.style.function
      return transition
    }
  }
  
  
  /// Change the root view controller of the window
  ///
  /// - Parameters:
  ///   - controller: controller to set
  ///   - options: options of the transition
  public func setRootViewController(_ controller: UIViewController, options: TransitionOptions = TransitionOptions()) {
    
    var transitionWnd: UIWindow? = nil
    if let background = options.background {
      transitionWnd = UIWindow(frame: UIScreen.main.bounds)
      switch background {
      case .customView(let view):
        transitionWnd?.rootViewController = UIViewController.newController(withView: view, frame: transitionWnd!.bounds)
      case .solidColor(let color):
        transitionWnd?.backgroundColor = color
      }
      transitionWnd?.makeKeyAndVisible()
    }
    
    // Make animation
    self.layer.add(options.animation, forKey: kCATransition)
    self.rootViewController = controller
    self.makeKeyAndVisible()
    
    if let wnd = transitionWnd {
      DispatchQueue.main.asyncAfter(deadline: (.now() + 1 + options.duration), execute: {
        wnd.removeFromSuperview()
      })
    }
  }
}

internal extension UIViewController {
  
  /// Create a new empty controller instance with given view
  ///
  /// - Parameters:
  ///   - view: view
  ///   - frame: frame
  /// - Returns: instance
  static func newController(withView view: UIView, frame: CGRect) -> UIViewController {
    view.frame = frame
    let controller = UIViewController()
    controller.view = view
    return controller
  }
  
}
