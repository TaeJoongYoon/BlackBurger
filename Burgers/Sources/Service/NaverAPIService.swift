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
    "X-NCP-APIGW-API-KEY-ID": PrivateKey.naverAPIKeyID,
    "X-NCP-APIGW-API-KEY": PrivateKey.naverAPIKey
  ]
  
  // MARK: Initialize
  
  private init() { }
  
  // MARK: DataTask
  
  func fetchPlaces(query: String, coordinate: String) -> Single<NetworkResult<[Place]>> {
    let url = "https://naveropenapi.apigw.ntruss.com/map-place/v1/search"
    param["query"] = query
    param["coordinate"] = coordinate
    
    return Single.create { [weak self] single in
      let request = Alamofire.request(
        url,
        method: .get,
        parameters: self?.param,
        headers: self?.header
        )
        .responseData { response in
          
          log.verbose("Parameter : ", self?.param ?? "none")
          log.verbose("Header : ", self?.header ?? "none")
          log.verbose("Response : ", String(data: response.data!, encoding: .utf8) ?? "none")
          
          switch response.result {
          case let .success(jsonData):
            do {
              let accessToken = try JSONDecoder().decode(PlaceResult.self, from: jsonData)
              log.info(accessToken)
              single(.success(.success(accessToken.places)))
            } catch let error {
              log.error(error)
              single(.error(error))
            }
            
          case let .failure(error):
            log.error(error)
            if let statusCode = response.response?.statusCode {
              if let networkError = NetworkError(rawValue: statusCode){
                single(.success(.error(networkError)))
              }
            }
            
          }
      }
      
      return Disposables.create {
        request.cancel()
      }
    }
  }
  
  
  
  
  
  struct Success: Codable {
    
  }
  
  struct Successs: Codable {
    
  }
  
  
  func requestA(parameters: Parameters, headers: HTTPHeaders) -> Single<NetworkResult<Success>> {
    return requestGeneric(parameters: parameters, headers: headers)
  }
  
  func requestB(parameters: Parameters, headers: HTTPHeaders) -> Single<NetworkResult<Successs>> {
    return requestGeneric(parameters: parameters, headers: headers)
  }
  
  func requestGeneric<C: Codable>(parameters: Parameters, headers: HTTPHeaders) -> Single<NetworkResult<C>> {
    return Single.create { single in
      let request = Alamofire.request(  // Networking에는 Alamofire를 사용했다.
        "url",
        method: .get,
        parameters: parameters,
        headers: headers
        )
        .responseData { response in
          
          switch response.result {
          case let .success(jsonData):
            do {
              let successReturnObject = try JSONDecoder().decode(C.self, from: jsonData)
              single(.success(.success(successReturnObject)))
              // single의 success. NetworkResult.success에 담아 보낸다.
            } catch let error {
              single(.error(error))
              // JSON 파싱에러 각자 알맞게 처리해주면 될 것 같다.
            }
            
          case let .failure(error):
            if let statusCode = response.response?.statusCode {
              if let networkError = NetworkError(rawValue: statusCode){
                single(.success(.error(networkError)))
                // single의 success. NetworkResult.error에 담아 보낸다.
              }
            }
          }
      }
      
      return Disposables.create {
        request.cancel()
      }
    }
  }
  
  
  
  
  
  
  
}
