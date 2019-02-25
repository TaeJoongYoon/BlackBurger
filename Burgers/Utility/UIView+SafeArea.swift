//
//  UIView+SafeArea.swift
//  Burgers
//
//  Created by Tae joong Yoon on 25/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import SnapKit

extension UIView {
  
  var safeArea: ConstraintBasicAttributesDSL {
    
    #if swift(>=3.2)
    if #available(iOS 11.0, *) {
      return self.safeAreaLayoutGuide.snp
    }
    return self.snp
    #else
    return self.snp
    #endif
  }
}
