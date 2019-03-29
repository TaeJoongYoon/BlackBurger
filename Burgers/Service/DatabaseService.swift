//
//  FirebaseDatabase.swift
//  Burgers
//
//  Created by Tae joong Yoon on 10/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import Photos

import FirebaseFirestore
import FirebaseStorage
import RxCocoa
import RxSwift

class DatabaseService: DatabaseServiceType {
  
  // MARK: Properties
  
  static let shared = DatabaseService()
  
  var db = Firestore.firestore()
  var storage = Storage.storage().reference()
  
  var from = 0
  
  // MARK: Initialize
  
  private init() { }
  
  // MARK: Datatask
  
  func writePost(images: [PHAsset], rating: Double, content: String, restaurant: String, place: Place) -> Single<Bool> {
    
    var imageStrings: [String] = []
    for i in 0..<images.count {
      imageStrings.append("\((AuthService.shared.user?.email)!)-\(images[i].localIdentifier).png")
    }
    
    return Single<Bool>.create { single in
      
      let post = Post(author: (AuthService.shared.user?.email)!,
                      content: content,
                      rating: rating,
                      likes: 0,
                      likeUser: [],
                      imageURLs: [],
                      restaurant: restaurant,
                      address: place.jibunAddress)
      
      var ref: DocumentReference? = nil
      ref = self.db.collection("posts").addDocument(data: post.uploadForm()) { err in
        if let error = err {
          log.error(error)
          single(.success(false))
        }
      }
      
      var imageURLs: [String] = []
      
      for (i, url) in imageStrings.enumerated() {
        self.storage.child(url).putData(
          self.imageFrom(asset: images[i]).pngData()!,
          metadata: nil
        ) { (metadata, error) in
          self.storage.child(url).downloadURL { (url, error) in
            if error != nil { single(.success(false)) }
            
            guard let downloadURL = url else { return }
            imageURLs.append(downloadURL.absoluteString)
            
            if imageURLs.count == images.count {
              self.db.collection("posts").document((ref?.documentID)!).updateData([
                "imageURLs": imageURLs
                ])
              
              self.db.collection("restaurants").addDocument(data: place.uploadForm())
              
              single(.success(true))
            }
          }
        }
      }
      
      return Disposables.create()
    }
    
  }
  
  func fetchRecentPosts(loading: Loading) -> Single<[Post]> {
    let first = self.db.collection("posts").limit(to: 20)
    var next = self.db.collection("posts").limit(to: 20)
    
    var query = first
    
    switch loading {
    case .refresh:
      query = first
    case .loadMore:
      query = next
    }
    
    return Single<[Post]>.create { single in
      
      var posts = [Post]()
      
      query.addSnapshotListener { (snapshot, error) in
        
        guard let snapshot = snapshot else {
          single(.success([]))
          return
        }
        
        for document in snapshot.documents {
          let post = Post(dictionary: document.data())
          posts.append(post)
        }
        
        guard let lastSnapshot = snapshot.documents.last else { return }
        next = next.start(afterDocument: lastSnapshot)

        single(.success(posts))
      }
      
      return Disposables.create()
    }
    
  }
  
  func fetchPopularPosts() -> Single<[Post]> {
    return Single<[Post]>.create { single in
      
      var posts = [Post]()
      
      self.db.collection("posts")
        .order(by: "likes", descending: true)
        .limit(to: 20).addSnapshotListener { (snapshot, error) in
          
          guard let snapshot = snapshot else {
            single(.success([]))
            return
          }
          
          for document in snapshot.documents {
            let post = Post(dictionary: document.data())
            posts.append(post)
          }
          
          single(.success(posts))
      }
      
      return Disposables.create()
    }
  }
  
  func fetchRestaurants() -> Single<[Place]> {
    return Single<[Place]>.create { single in
      
      var restaurants = [Place]()
      
      self.db.collection("restaurants")
        .addSnapshotListener { (snapshot, error) in
          
          guard let snapshot = snapshot else {
            single(.success([]))
            return
          }
          
          for document in snapshot.documents {
            let restaurant = Place(dictionary: document.data())
            restaurants.append(restaurant)
          }
          
          single(.success(restaurants))
      }
      
      return Disposables.create()
    }
  }
  
  func fetchPosts(from restaurant: String) -> Single<[Post]> {
    return Single<[Post]>.create { single in
      
      var posts = [Post]()
      
      self.db.collection("posts")
        .whereField("restaurant", isEqualTo: restaurant)
        .getDocuments() { (querySnapshot, err) in
          if let err = err {
            print("Error getting documents: \(err)")
          } else {
            for document in querySnapshot!.documents {
              let post = Post(dictionary: document.data())
              posts.append(post)
            }
          }
          single(.success(posts))
        }
      
      return Disposables.create()
    }
  }
  
  func fetchMyPosts() -> Single<[Post]> {
    return Single<[Post]>.create { single in
      
      var posts = [Post]()
      
      self.db.collection("posts")
        .whereField("author", isEqualTo: (AuthService.shared.user?.email)!)
        .getDocuments() { (querySnapshot, err) in
          if let err = err {
            print("Error getting documents: \(err)")
          } else {
            for document in querySnapshot!.documents {
              let post = Post(dictionary: document.data())
              posts.append(post)
            }
          }
          single(.success(posts))
      }
      
      return Disposables.create()
    }
  }
  
  func fetchLikesPosts() -> Single<[Post]> {
    return Single<[Post]>.create { single in
      
      var posts = [Post]()
      
      self.db.collection("posts")
        .whereField("likeUsers", arrayContains: (AuthService.shared.user?.email)!)
        .getDocuments() { (querySnapshot, err) in
          if let err = err {
            print("Error getting documents: \(err)")
          } else {
            for document in querySnapshot!.documents {
              let post = Post(dictionary: document.data())
              posts.append(post)
            }
          }
          single(.success(posts))
      }
      
      return Disposables.create()
    }
  }
  
  private func imageFrom(asset: PHAsset) -> UIImage {
    let manager = PHImageManager.default()
    let option = PHImageRequestOptions()
    var image = UIImage()
    option.isSynchronous = true
    manager.requestImage(for: asset,
                         targetSize: CGSize(width: 400.0, height: 400.0),
                         contentMode: .aspectFit,
                         options: option,
                         resultHandler: {(result, info)->Void in
                          image = result!
    })
    return image
  }
}

