//
//  String+Localized.swift
//  Burgers
//
//  Created by Tae joong Yoon on 26/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import Foundation

extension String {
  var localized: String {
    return NSLocalizedString(self, comment: "")
  }
}
