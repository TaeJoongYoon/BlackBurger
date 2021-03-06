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
  
  fileprivate struct Metric {
    static let segmentedHeight = 45
    static let segmentedBorderWidth = CGFloat(5.0)
  }
  
  // MARK: Properties
  
  fileprivate let viewModel: SuggestedViewModelType
  fileprivate let contentTabView: ContentTabViewController
  fileprivate let presentPostScreen: ([PHAsset]) -> PostViewController
  
  // MARK: UI
  
  let addButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: nil).then {
    $0.tintColor = .tintColor
  }
  
  // MARK: Initalize
  
  init(
    viewModel: SuggestedViewModelType,
    contentTabView: ContentTabViewController,
    presentPostScreen: @escaping ([PHAsset]) -> PostViewController
    ) {
    self.viewModel = viewModel
    self.contentTabView = contentTabView
    self.presentPostScreen = presentPostScreen
    super.init()
    self.tabBarItem.image = UIImage(named: "hamburger-unselected.png")
    self.tabBarItem.selectedImage = UIImage(named: "hamburger-selected.png")
    self.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Setup UI
  
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
  
  override func bindingEvent() {
    
    self.addButton.rx.tap
      .debounce(0.3, scheduler: MainScheduler.instance)
      .bind(to: viewModel.inputs.didTappedAddButton)
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: - <- Rx UI Binding
  
  override func bindingUI() {
    
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
  
  private func photosNotPermission() {
    let alertController = UIAlertController(
      title: "Photos and Camera Not Available".localized,
      message: "Please allow this access in \n Settings > BlackBurger > Photos".localized,
      preferredStyle: .alert
    )
    
    let settingsAction = UIAlertAction(title: "Settings".localized, style: .default) { _ in
      guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
      UIApplication.shared.open(settingsURL, completionHandler: nil)
    }
    let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
    
    alertController.addAction(cancelAction)
    alertController.addAction(settingsAction)
    
    present(alertController, animated: true, completion: nil)
  }
  
}


extension SuggestedViewController: TLPhotosPickerViewControllerDelegate {

  func dismissPhotoPicker(withPHAssets: [PHAsset]) {
     // if you want to used phasset.
    
    if withPHAssets.count > 0 {
      let viewController = self.presentPostScreen(withPHAssets)
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
    photosNotPermission()
  }
  
  func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
    photosNotPermission()
  }
}
