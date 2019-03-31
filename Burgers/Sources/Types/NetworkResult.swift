//
//  NetworkResult.swift
//  Burgers
//
//  Created by Tae joong Yoon on 30/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import Foundation

enum NetworkResult<C: Codable> {
  case success(C)
  case error(NetworkError)
  case none
}
