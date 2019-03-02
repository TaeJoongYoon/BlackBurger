//
//  FirebaseServiceType.swift
//  Burgers
//
//  Created by Tae joong Yoon on 02/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import RxSwift

protocol FirebaseServiceType {
  func fetchRecentPosts() -> Observable<[Post]>
}
