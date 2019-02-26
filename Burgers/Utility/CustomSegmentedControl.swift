//
//  CustomSegmentedControl.swift
//  Burgers
//
//  Created by Tae joong Yoon on 26/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import UIKit

@IBDesignable
class CustomSegmentedControl: UIControl {
  
  var buttons = [UIButton]()
  var selector: UIView!
  var selectedSegmentIndex = 0
  
  @IBInspectable var borderWidth: CGFloat = 0 {
    didSet {
      layer.borderWidth = borderWidth
    }
  }
  
  @IBInspectable var cornerRadius: CGFloat = 0 {
    didSet {
      layer.cornerRadius = cornerRadius
    }
  }
  
  @IBInspectable var borderColor: UIColor = .clear {
    didSet {
      layer.borderColor = borderColor.cgColor
    }
  }
  
  @IBInspectable var titles: [String] = [""]
  
  @IBInspectable var textColor: UIColor = .lightGray
  
  
  @IBInspectable var selectorColor: UIColor = .darkGray
  
  @IBInspectable var selectorTextColor: UIColor = .green
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    //updateView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    fatalError("init(coder:) has not been implemented")
  }
  
  func updateView(width: CGFloat, height: CGFloat) {
    
    buttons.removeAll()
    subviews.forEach { (view) in
      view.removeFromSuperview()
    }
    
    for title in titles {
      let button = UIButton.init(type: .system)
      button.setTitle(title, for: .normal)
      button.setTitleColor(textColor, for: .normal)
      button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
      buttons.append(button)
    }
    
    buttons[0].setTitleColor(selectorTextColor, for: .normal)
    
    //let y = (self.frame.maxY - self.frame.minY) - 3.0
    print(height)
    let selectorWidth = width / CGFloat(titles.count)
    selector = UIView.init(frame: CGRect.init(x: 0, y: height-3.0, width: selectorWidth, height: 3.0))
    selector.backgroundColor = selectorColor
    addSubview(selector)
    
    // Create a StackView
    
    let stackView = UIStackView.init(arrangedSubviews: buttons)
    stackView.axis = .horizontal
    stackView.alignment = .fill
    stackView.distribution = .fillEqually
    stackView.spacing = 0.0
    addSubview(stackView)
    
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    stackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
    stackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    
  }
  
  // Only override draw() if you perform custom drawing.
  // An empty implementation adversely affects performance during animation.
  override func draw(_ rect: CGRect) {
    
    // Drawing code
    
    // layer.cornerRadius = frame.height/2
    
  }
  
  
  @objc func buttonTapped(button: UIButton) {
    
    
    for (buttonIndex,btn) in buttons.enumerated() {
      
      btn.setTitleColor(textColor, for: .normal)
      
      if btn == button {
        selectedSegmentIndex = buttonIndex
        
        let  selectorStartPosition = frame.width / CGFloat(buttons.count) * CGFloat(buttonIndex)
        
        UIView.animate(withDuration: 0.3, animations: {
          
          self.selector.frame.origin.x = selectorStartPosition
        })
        
        btn.setTitleColor(selectorTextColor, for: .normal)
      }
    }
    
    sendActions(for: .valueChanged)
    
    
    
    
  }
  
  
  func updateSegmentedControlSegs(index: Int) {
    
    for btn in buttons {
      btn.setTitleColor(textColor, for: .normal)
    }
    
    let  selectorStartPosition = frame.width / CGFloat(buttons.count) * CGFloat(index)
    
    UIView.animate(withDuration: 0.3, animations: {
      
      self.selector.frame.origin.x = selectorStartPosition
    })
    
    buttons[index].setTitleColor(selectorTextColor, for: .normal)
    
  }
  
  
  
  //    override func sendActions(for controlEvents: UIControlEvents) {
  //
  //        super.sendActions(for: controlEvents)
  //
  //        let  selectorStartPosition = frame.width / CGFloat(buttons.count) * CGFloat(selectedSegmentIndex)
  //
  //        UIView.animate(withDuration: 0.3, animations: {
  //
  //            self.selector.frame.origin.x = selectorStartPosition
  //        })
  //
  //        buttons[selectedSegmentIndex].setTitleColor(selectorTextColor, for: .normal)
  //
  //    }
  
  
  
}
