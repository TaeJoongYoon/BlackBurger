//
//  ModelType.swift
//  Burgers
//
//  Created by Tae joong Yoon on 24/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import Then

protocol ModelType: Codable, Then {
  associatedtype Event
  
  static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get }
}

extension ModelType {
  static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy {
    return .iso8601
  }
  
  static var decoder: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = self.dateDecodingStrategy
    return decoder
  }
}
