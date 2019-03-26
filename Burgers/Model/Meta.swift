//
//  Meta.swift
//  Burgers
//
//  Created by Tae joong Yoon on 24/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import Foundation

struct Meta: ModelType {
  enum Event {
  }
  
  var totalCount: Int
  var count: Int
  
  enum CodingKeys: String, CodingKey {
    case totalCount = "totalCount"
    case count = "count"
  }
}
