//
//  NetworkError.swift
//  Burgers
//
//  Created by Tae joong Yoon on 30/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import Foundation

enum NetworkError: Int, Error {
  case badRequest = 400
  case authenticationFailed = 401
  case notFoundException = 404
  case contentLengthError = 413
  case quotaExceeded = 429
  case systemError = 500
  case endpointError = 503
  case timeout = 504
}
