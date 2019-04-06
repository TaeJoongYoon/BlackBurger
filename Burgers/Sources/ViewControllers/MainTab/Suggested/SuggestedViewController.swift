//
//  SuggestedViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 25/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import Photos

import Kingfisher
import RxCocoa
import RxSwift
import Then
import TLPhotoPicker
import Toaster

final class SuggestedViewController: BaseViewController {
  
  // MARK: Constants
  
  private struct Metric {
    static let segmentedHeight = 45
    static let segmentedBorderWidth = CGFloat(5.0)
  }
  
  // MARK: Properties
  
  var viewModel: SuggestedViewModelType!
  
  // MARK: UI
  
  let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil).then {
    $0.tintColor = .tintColor
  }
  
  let contentTabView = ContentTabViewController()
  
  // MARK: Setup UI
  
  override init() {
    super.init()
    self.tabBarItem.image = UIImage(named: "hamburger-unselected.png")
    self.tabBarItem.selectedImage = UIImage(named: "hamburger-selected.png")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "BLACK BURGER".localized
    let backBarButtton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    self.navigationItem.backBarButtonItem = backBarButtton
    
    self.view.backgroundColor = .white
    self.tabBarItem.image = UIImage(named: "hamburger-unselected.png")
    self.tabBarItem.selectedImage = UIImage(named: "hamburger-selected.png")
    
    self.navigationItem.rightBarButtonItem = self.addButton
    
    self.addChild(contentTabView)
    self.view.addSubview(contentTabView.view)
    self.contentTabView.didMove(toParent: self)
  }
  
  // MARK: Setup Constraints
  
  override func setupConstraints() {
    
    self.contentTabView.view.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeArea.top)
      make.left.right.equalToSuperview()
      make.bottom.equalTo(self.view.safeArea.bottom)
    }
    
  }
  
  // MARK: - -> Rx Event Binding
  
  override func eventBinding() {
    
    self.addButton.rx.tap
      .debounce(0.3, scheduler: MainScheduler.instance)
      .bind(to: viewModel.inputs.didTappedAddButton)
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: - <- Rx UI Binding
  
  override func uiBinding() {
    
    viewModel.outputs.add
      .drive(onNext: { [weak self] in
        self?.showPhotoPicker()
      })
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: Action Handler
  
  private func showPhotoPicker() {
    let viewController = TLPhotosPickerViewController()
    viewController.delegate = self
    
    var configure = TLPhotosPickerConfigure()
    configure.doneTitle = "Done".localized
    configure.cancelTitle = "Cancel".localized
    configure.defaultCameraRollTitle = "All Photos".localized
    configure.allowedVideo = false
    configure.selectedColor = .tintColor
    configure.maxSelectedAssets = 10
    viewController.configure = configure
    
    self.present(viewController, animated: true, completion: nil)
  }
  
}


extension SuggestedViewController: TLPhotosPickerViewControllerDelegate {

  func dismissPhotoPicker(withPHAssets: [PHAsset]) {
     // if you want to used phasset.
    
    if withPHAssets.count > 0 {
      let viewController = appDelegate.container.resolve(PostViewController.self, argument: withPHAssets)!
      viewController.hidesBottomBarWhenPushed = true
      self.navigationController?.pushViewController(viewController, animated: true)
    } else {
      Toast(text: "Please select photos at least one".localized, duration: Delay.short).show()
    }
  }
  
  func canSelectAsset(phAsset: PHAsset) -> Bool {
    //Custom Rules & Display
    //You can decide in which case the selection of the cell could be forbidden.
    
    return true
  }
  
  func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
    
    // exceed max selection
  }
  
  func handleNoAlbumPermissions(picker: TLPhotosPickerViewController) {
    Toast(text: "Album permission denied, Please allow it".localized, duration: Delay.short).show()
  }
  
  func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
    Toast(text: "Camera permission denied, Please allow it".localized, duration: Delay.short).show()
  }
}
