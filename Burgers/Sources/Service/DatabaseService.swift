//
//  FirebaseDatabase.swift
//  Burgers
//
//  Created by Tae joong Yoon on 10/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import Photos

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import RxCocoa
import RxSwift

class DatabaseService: DatabaseServiceType {
  
  // MARK: Properties
  
  static let shared = DatabaseService()
  
  var db = Firestore.firestore()
  var storage = Storage.storage()
  
  var next = Firestore.firestore().collection("posts")
      .order(by: "createdAt", descending: true)
      .limit(to: 20)
  
  // MARK: Initialize
  
  private init() { }
  
  // MARK: Datatask
  
  func writePost(images: [PHAsset], rating: Double, content: String, restaurant: String, place: Place) -> Single<Bool> {
    
    var imageStrings: [String] = []
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssSSSZZZZZ"
    
    for i in 0..<images.count {
      let date = Date()
      imageStrings.append("\((Auth.auth().currentUser?.email)!)-\(dateFormatter.string(from: date))-\(i).png")
    }
    
    return Single<Bool>.create { single in
      
      let post = Post(author: (Auth.auth().currentUser?.email)!,
                      content: content,
                      rating: rating,
                      likes: 0,
                      likeUser: [],
                      imageURLs: [],
                      restaurant: restaurant,
                      address: place.jibunAddress,
                      createdAt: Date())
      
      var ref: DocumentReference? = nil
      ref = self.db.collection("posts").addDocument(data: post.uploadForm()) { err in
        if let error = err {
          log.error(error)
          single(.success(false))
        }
      }
      
      var imageURLs: [String] = []
      
      for (i, url) in imageStrings.enumerated() {
        self.storage.reference().child(url).putData(
          self.imageFrom(asset: images[i]).pngData()!,
          metadata: nil
        ) { (metadata, error) in
          self.storage.reference().child(url).downloadURL { (url, error) in
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
    let first = self.db.collection("posts").order(by: "createdAt", descending: true).limit(to: 20)
    var query = first
    
    if loading == .loadMore {
      query = self.next
    }
    
    return Single<[Post]>.create { single in
      
      var posts = [Post]()
      
      query.getDocuments { document, error in
        if error != nil {
          log.error(error!)
          single(.success([]))
        } else {
          if let documents = document?.documents {
            for document in documents {
              let post = Post(dictionary: document.data())
              posts.append(post)
            }
            
            if let last = documents.last {
              self.next = self.next.start(atDocument: last)
            }
          }
        }
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
        .limit(to: 20).getDocuments { document, error in
          if error != nil {
            log.error(error!)
            single(.success([]))
          } else {
            if let documents = document?.documents {
              for document in documents {
                let post = Post(dictionary: document.data())
                posts.append(post)
              }
            }
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
        .getDocuments { document, error in
          if error != nil {
            log.error(error!)
            single(.success([]))
          } else {
            if let documents = document?.documents {
              for document in documents {
                let restaurant = Place(dictionary: document.data())
                restaurants.append(restaurant)
              }
            }
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
  
  func fetchPosts(isMyPosts: Bool) -> Single<[Post]> {
    var query: Query
    
    if isMyPosts {
      query = self.db.collection("posts")
        .whereField("author", isEqualTo: (Auth.auth().currentUser?.email)!)
    } else {
      query = self.db.collection("posts")
        .whereField("likeUser", arrayContains: (Auth.auth().currentUser?.email)!)
    }
    
    return Single<[Post]>.create { single in
      
      var posts = [Post]()
      
      query.getDocuments() { (querySnapshot, err) in
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
  
  func removeAll(from author: String) {
    
    var deleteStorageURL: [String] = []
    
    self.db.collection("posts").whereField("author", isEqualTo: author).getDocuments { (querySnapshot, err) in
      if let err = err {
        print("Error getting documents: \(err)")
      } else {
        
        for document in querySnapshot!.documents {
          let post = Post(dictionary: document.data())
          deleteStorageURL.append(contentsOf: post.imageURLs)
          
          document.reference.delete()
        }
        
        for ref in deleteStorageURL {
          self.storage.reference(forURL: ref).delete { error in
            if let error = error {
              log.error(error)
            }
          }
        }
      }
    }
    
    self.db.collection("posts").whereField("likeUser", arrayContains: author).getDocuments { (querySnapshot, err) in
      if let err = err {
        print("Error getting documents: \(err)")
      } else {
        
        for document in querySnapshot!.documents {
          
          self.db.runTransaction({ (transaction, errorPointer) -> Any? in
            let postsDocument: DocumentSnapshot
            do {
              try postsDocument = transaction.getDocument(document.reference)
            } catch let fetchError as NSError {
              errorPointer?.pointee = fetchError
              return nil
            }
            
            guard let oldLikes = postsDocument.data()?["likes"] as? Int else {
              let error = NSError(
                domain: "AppErrorDomain",
                code: -1,
                userInfo: [
                  NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(postsDocument)"
                ]
              )
              errorPointer?.pointee = error
              return nil
            }
            
            let newLikes = oldLikes - 1
            guard newLikes >= 0 else {
              let error = NSError(
                domain: "AppErrorDomain",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Population \(newLikes) too big"]
              )
              errorPointer?.pointee = error
              return nil
            }
            
            transaction.updateData(["likes": newLikes], forDocument: document.reference)
            return newLikes
          }) { (object, error) in
            if let error = error {
              print("Error updating population: \(error)")
            } else {
              print("Population increased to \(object!)")
            }
          }
          
          document.reference.updateData([
            "likeUser": FieldValue.arrayRemove([author])
            ])
        }
      }
    }
  }
  
  private func imageFrom(asset: PHAsset) -> UIImage {
    let manager = PHImageManager.default()
    let option = PHImageRequestOptions()
    var image = UIImage()
    option.isSynchronous = true
    manager.requestImage(for: asset,
                         targetSize: CGSize(width: 1080.0, height: 1080.0),
                         contentMode: .aspectFit,
                         options: option,
                         resultHandler: {(result, info)->Void in
                          image = result!
    })
    return image
  }
}

