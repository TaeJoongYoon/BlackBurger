//
//  NaverAPIService.swift
//  Burgers
//
//  Created by Tae joong Yoon on 24/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import Foundation

import Alamofire
import RxCocoa
import RxSwift

class NaverAPIService: NaverAPIServiceType {
  
  // MARK: Properties
  
  static let shared = NaverAPIService()
  var param = [String: String]()
  
  let header = [
    "X-NCP-APIGW-API-KEY-ID": "0hvz2ykiw6",
    "X-NCP-APIGW-API-KEY": "dEhTAIgIgFzR9XDsWTHyiWiQsMSrIhDRU2viOeOH"
  ]
  
  // MARK: Initialize
  
  private init() { }
  
  // MARK: DataTask
  
  func fetchPlaces(query: String, coordinate: String) -> Single<[Place]> {
    param["query"] = query
    param["coordinate"] = "126.8400960,37.5692690"
    
    return Single.create { [weak self] single in
      let request = Alamofire.request("https://naveropenapi.apigw.ntruss.com/map-place/v1/search",
                                      method: .get,
                                      parameters: self?.param,
                                      headers: self?.header)
        .responseData { response in
          
          log.verbose("Parameter : ", self?.param)
          log.verbose("Header : ", self?.header)
          log.verbose("Response : ", String(data: response.data!, encoding: .utf8))
          
          switch response.result {
          case let .success(jsonData):
            do {
              let accessToken = try JSONDecoder().decode(PlaceResult.self, from: jsonData)
              log.info(accessToken)
              single(.success(accessToken.places))
            } catch let error {
              log.error(error)
            }
            
          case let .failure(error):
            log.error(error)
            single(.error(error))
          }
      }
      
      return Disposables.create {
        request.cancel()
      }
    }
  }
  
}
