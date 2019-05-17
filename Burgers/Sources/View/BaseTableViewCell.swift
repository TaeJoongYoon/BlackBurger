//
//  BaseTableViewCell.swift
//  BlackBurger
//
//  Created by Tae joong Yoon on 17/05/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import UIKit

import RxSwift

class BaseTableViewCell: UITableViewCell {
  
  var disposeBag = DisposeBag()
  
  // MARK: Initializing
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    self.init(style: .default, reuseIdentifier: nil)
  }
  
}
