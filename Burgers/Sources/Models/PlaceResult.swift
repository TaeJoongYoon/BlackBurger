//
//  PlaceResult.swift
//  Burgers
//
//  Created by Tae joong Yoon on 24/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import Foundation

struct PlaceResult: ModelType {
  enum Event {
  }
  
  var status: String
  var meta: Meta
  var places: [Place]
  
  enum CodingKeys: String, CodingKey {
    case status = "status"
    case meta = "meta"
    case places = "places"
  }
}
