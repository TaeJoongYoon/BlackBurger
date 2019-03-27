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
  
  func writePost(images: [PHAsset], rating: Double, content: String, restaurant: String) -> Single<Bool> {
    
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
                    restaurant: restaurant)
    
    log.info("Post : ", post)
    
    var ref: DocumentReference? = nil
    ref = self.db.collection("posts").addDocument(data: post.uploadForm()) { err in
      if let error = err {
        log.error(error)
        single(.error(error))
      } else {
        log.info("DB Success")
      }
    }
    
      var imageURLs: [String] = []
      
      for (i, url) in imageStrings.enumerated() {
        self.storage.child(url).putData(self.imageFrom(asset: images[i]).pngData()!, metadata: nil) { (metadata, error) in
          self.storage.child(url).downloadURL { (url, error) in
            if error != nil {
              single(.error(error!))
            }
            
            guard let downloadURL = url else { return }
            imageURLs.append(downloadURL.absoluteString)
            if imageURLs.count == images.count {
              self.db.collection("posts").document((ref?.documentID)!).updateData([
                "imageURLs": imageURLs
                ])
              log.info("Photos Upload Success")
              single(.success(true))
            }
          }
        }
      }
      
      return Disposables.create()
    }
  
  }
  
  
  func fetchRecentPosts(loading: Loading) -> Observable<[Post]> {
    let first = self.db.collection("posts").limit(to: 20)
    var next = self.db.collection("posts").limit(to: 20)

    var query = first
    
    switch loading {
    case .refresh:
      query = first
    case .loadMore:
      query = next
    }
  
    return Observable.create { observer -> Disposable in
      
      var posts = [Post]()
      
      query.addSnapshotListener { (snapshot, error) in
    
        guard let snapshot = snapshot else {
          log.error(error ?? "error is nil")
          observer.onError(error!)
          return
        }
      
        for document in snapshot.documents {
         let post = Post(dictionary: document.data())
          posts.append(post)
        }
        
        guard let lastSnapshot = snapshot.documents.last else {
          // The collection is empty.
          return
        }
        
        next = next.start(afterDocument: lastSnapshot)
        
        observer.onNext(posts)
        observer.onCompleted()
      }
      
      return Disposables.create()
    }
  }
  
  func fetchPopularPosts() -> Observable<[Post]> {
    return Observable.create { observer -> Disposable in
      
      var posts = [Post]()
      
      self.db.collection("posts")
        .order(by: "likes", descending: true)
        .limit(to: 20).addSnapshotListener { (snapshot, error) in
        
        guard let snapshot = snapshot else {
          log.error(error ?? "error is nil")
          observer.onError(error!)
          return
        }
        
        for document in snapshot.documents {
          let post = Post(dictionary: document.data())
          posts.append(post)
        }
        
        observer.onNext(posts)
        observer.onCompleted()
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
                         targetSize: CGSize(width: 200.0, height: 200.0),
                         contentMode: .aspectFit,
                         options: option,
                         resultHandler: {(result, info)->Void in
      image = result!
    })
    return image
  }
}

