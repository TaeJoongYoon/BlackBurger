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
  
  init(dictionary: [String: Any]) {
    self.name = dictionary["name"] as! String
    self.roadAddress = dictionary["roadAddress"] as! String
    self.jibunAddress = dictionary["jibunAddress"] as! String
    self.phoneNumber = dictionary["phoneNumber"] as! String
    self.x = dictionary["x"] as! String
    self.y = dictionary["y"] as! String
    self.distance = dictionary["distance"] as! Double
    self.sessionId = dictionary["sessionId"] as! String
  }
  
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
  
  func uploadForm() -> [String: Any] {
    return [
      "name": self.name,
      "roadAddress": self.roadAddress,
      "jibunAddress": self.jibunAddress,
      "phoneNumber": self.phoneNumber,
      "x": self.x,
      "y": self.y,
      "distance": self.distance,
      "sessionId": self.sessionId
    ]
  }
}
