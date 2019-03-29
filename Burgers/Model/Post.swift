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
  var address: String
  
  init(author: String, content: String, rating: Double, likes: Int, likeUser: [String],
       imageURLs: [String], restaurant: String, address: String) {
    self.author = author
    self.content = content
    self.rating = rating
    self.likes = likes
    self.likeUser = likeUser
    self.imageURLs = imageURLs
    self.restaurant = restaurant
    self.address = address
  }
  
  init(dictionary: [String: Any]) {
    self.author = dictionary["author"] as! String
    self.content = dictionary["content"] as! String
    self.rating = dictionary["rating"] as! Double
    self.likes = dictionary["likes"] as! Int
    self.likeUser = dictionary["likeUser"] as! [String]
    self.imageURLs = dictionary["imageURLs"] as! [String]
    self.restaurant = dictionary["restaurant"] as! String
    self.address = dictionary["address"] as! String
  }

  
  func uploadForm() -> [String: Any] {
    return [
      "author": self.author,
      "content": self.content,
      "rating": self.rating,
      "likes": self.likes,
      "likeUser": self.likeUser,
      "imageURLs": self.imageURLs,
      "restaurant": self.restaurant,
      "address": self.address
    ]
  }
}
