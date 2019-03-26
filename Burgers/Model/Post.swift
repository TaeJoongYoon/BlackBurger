//
//  Post.swift
//  Burgers
//
//  Created by Tae joong Yoon on 02/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import Foundation


struct Post {
  var author: String
  var content: String
  var rating: Double
  var likes: Int
  var likeUser: [String]
  var imageURLs: [String]
  var restaurant: String
  
  init(author: String, content: String, rating: Double, likes: Int, likeUser: [String],
       imageURLs: [String], restaurant: String) {
    self.author = author
    self.content = content
    self.rating = rating
    self.likes = likes
    self.likeUser = likeUser
    self.imageURLs = imageURLs
    self.restaurant = restaurant
  }
  
  func uploadForm() -> [String: Any] {
    return [
      "author": self.author,
      "content": self.content,
      "rating": self.rating,
      "likes": self.likes,
      "likeUser": self.likeUser,
      "imageURLs": self.imageURLs,
      "restaurant": self.restaurant
    ]
  }
}
