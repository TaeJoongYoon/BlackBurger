//
//  Place.swift
//  Burgers
//
//  Created by Tae joong Yoon on 24/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import Foundation

struct Place: ModelType {
  enum Event {
  }
  
  var name: String
  var roadAddress: String
  var jibunAddress: String
  var phoneNumber: String
  var x: String
  var y: String
  var distance: Double
  var sessionId: String
  
  
  enum CodingKeys: String, CodingKey {
    case name = "name"
    case roadAddress = "road_address"
    case jibunAddress = "jibun_address"
    case phoneNumber = "phone_number"
    case x = "x"
    case y = "y"
    case distance = "distance"
    case sessionId = "sessionId"
  }
}
