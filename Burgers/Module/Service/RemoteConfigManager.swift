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
    forceUpdate:@escaping (_ need: Bool)->()
    ) {
    
    let remoteConfig = RemoteConfig.remoteConfig()
    
    remoteConfig.fetch { (status, error) -> Void in
      
      log.error(error)
      log.verbose(status.hashValue)
      
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
        
        forceUpdate(needForcedUpdate)
        
        if needForcedUpdate {
          let alert = UIAlertController.init(title: "Update".localized,
                                             message: "forceUpdate".localized,
                                             preferredStyle: .alert)
          
          alert.addAction(UIAlertAction.init(title: "Update".localized,
                                             style: .default,
                                             handler: { (action) in
                                              self.appStore()
          }))
          
          var topController = UIApplication.shared.keyWindow?.rootViewController
          if topController != nil {
            while let presentedViewController = topController?.presentedViewController {
              topController = presentedViewController
            }
          }
          topController!.present(alert, animated: false, completion: nil)
        }
        
        
        // Optional update
        let needUpdate:Bool = (self.compareVersion(versionA: appVersion, versionB: appConfig.minVersion) != ComparisonResult.orderedAscending) &&
          (self.compareVersion(versionA: appVersion, versionB: appConfig.lastestVersion) == ComparisonResult.orderedAscending)
        
        if needUpdate {
          let alert = UIAlertController.init(title: "Update".localized,
                                             message: "optionalUpdate".localized,
                                             preferredStyle: .alert)
          
          alert.addAction(UIAlertAction.init(title: "Update".localized,
                                             style: .default,
                                             handler: { (action) in
                                              self.appStore()
          }))
          
          alert.addAction(UIAlertAction.init(title: "Later".localized,
                                             style: .default,
                                             handler: nil))
          
          var topController = UIApplication.shared.keyWindow?.rootViewController
          if topController != nil {
            while let presentedViewController = topController?.presentedViewController {
              topController = presentedViewController
            }
          }
          
          topController!.present(alert, animated: false, completion: nil)
        }
        
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
    return ComparisonResult.orderedSame
  }
  
  private func appStore() {
    let appStoreAppID = "1111111111"
    let url = URL(string: "itms-apps://itunes.apple.com/app/id" + appStoreAppID)!
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
  
}
