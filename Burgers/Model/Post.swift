//
//  Post.swift
//  Burgers
//
//  Created by Tae joong Yoon on 02/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import Foundation

struct Post: Decodable {
  let name: String
}

struct Posts: Decodable {
  let items: [Post]
}
