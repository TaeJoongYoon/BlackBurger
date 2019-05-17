//
//  RemoteConfigManager.swift
//  Burgers
//
//  Created by Tae joong Yoon on 10/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import UIKit
import Firebase

class AppConfig {
  var lastestVersion: String?
  var minVersion: String?
}


class RemoteConfigManager: NSObject {
  
  static let shared = RemoteConfigManager()
  
  override private init() {}
  
  public func launching(
    completionHandler: @escaping (_ conf: AppConfig) -> (),
    update:@escaping (_ force: Bool, _ need: Bool)->()
    ) {
    
    let remoteConfig = RemoteConfig.remoteConfig()
    
    remoteConfig.fetch { (status, error) -> Void in
      
      if let error = error {
        log.error(error)
      }
      log.verbose(status)
      
      if status == .success {
        remoteConfig.activateFetched()
        
        // Fetch version data
        let appConfig = AppConfig()
        appConfig.lastestVersion = remoteConfig["lastest_version"].stringValue
        appConfig.minVersion = remoteConfig["min_version"].stringValue
        
        completionHandler(appConfig)
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        
        log.info("current_version : \(appVersion)")
        log.info("lastest_version : \(String(describing: appConfig.lastestVersion))")
        log.info("min_version : \(String(describing: appConfig.minVersion))")
        
        // Force update
        let needForcedUpdate: Bool = (self.compareVersion(versionA: appVersion, versionB: appConfig.minVersion) == ComparisonResult.orderedAscending)
        
        // Optional update
        let needUpdate:Bool = (self.compareVersion(versionA: appVersion, versionB: appConfig.minVersion) != ComparisonResult.orderedAscending) &&
          (self.compareVersion(versionA: appVersion, versionB: appConfig.lastestVersion) == ComparisonResult.orderedAscending)
        
        update(needForcedUpdate, needUpdate)
        
      }
    }
  }
  
  private func compareVersion(versionA: String, versionB: String!) -> ComparisonResult {
    let majorA = Int(Array(versionA.split(separator: "."))[0])!
    let majorB = Int(Array(versionB.split(separator: "."))[0])!
   
    if majorA > majorB {
      return ComparisonResult.orderedDescending
    } else if majorB > majorA {
      return ComparisonResult.orderedAscending
    }
    
    let minorA = Int(Array(versionA.split(separator: "."))[1])!
    let minorB = Int(Array(versionB.split(separator: "."))[1])!
    if minorA > minorB {
      return ComparisonResult.orderedDescending
    } else if minorB > minorA {
      return ComparisonResult.orderedAscending
    }
    
    let subA = Int(Array(versionA.split(separator: "."))[2])!
    let subB = Int(Array(versionB.split(separator: "."))[2])!
    if subA > subB {
      return ComparisonResult.orderedDescending
    } else if subB > subA {
      return ComparisonResult.orderedAscending
    }
    
    return ComparisonResult.orderedSame
  }
  
}
