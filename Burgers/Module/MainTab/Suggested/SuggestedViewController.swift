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

final class SuggestedViewController: UIViewController, ViewType {
  
  // MARK: Constants
  
  struct Reusable {
    
  }
  
  struct Constant {
    
  }
  
  private struct Metric {
    static let segmentedHeight = 45
    static let segmentedBorderWidth = CGFloat(5.0)
  }
  
  // MARK: Rx
  
  var disposeBag: DisposeBag!
  
  // MARK: Properties
  
  var viewModel: SuggestedViewModelType!
  
  // MARK: UI
  let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil).then {
    $0.tintColor = .tintColor
  }
  
  let segmentedControl = UISegmentedControl(items: ["RECENT".localized, "POPULAR".localized]).then {
    $0.backgroundColor = .white
    $0.tintColor = .mainColor
    $0.layer.borderColor = UIColor.white.cgColor
    $0.layer.borderWidth = Metric.segmentedBorderWidth
    $0.selectedSegmentIndex = 0
  }
  
  let containerView = UIView(frame: .zero)
  
  let scrollView = UIScrollView(frame: .zero).then {
    $0.isPagingEnabled = true
    $0.isDirectionalLockEnabled = true
    $0.contentInsetAdjustmentBehavior = .never
  }
  
  let recentView = RecentViewController.create(with: RecentViewModel())
  
  let popularView = PopularViewController.create(with: PopularViewModel())
  
  // MARK: Setup UI
  
  func setupUI() {
    self.navigationItem.title = "BURGERS".localized
    self.view.backgroundColor = .white
    self.tabBarItem.image = UIImage(named: "hamburger-unselected.png")
    self.tabBarItem.selectedImage = UIImage(named: "hamburger-selected.png")
    self.navigationItem.rightBarButtonItem = self.addButton
    self.view.addSubview(self.segmentedControl)
    
    // Use ContainerView for UIViewController in UIScrollView
    add([self.recentView, self.popularView], to: self.containerView)
    
    self.scrollView.addSubview(self.containerView)

    self.view.addSubview(self.scrollView)
  }
  
  // MARK: Setup Constraints
  
  func setupConstraints() {
    
    self.segmentedControl.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeArea.top)
      make.left.right.equalTo(self.view)
      make.height.equalTo(Metric.segmentedHeight)
    }

    self.scrollView.snp.makeConstraints { make in
      make.top.equalTo(self.segmentedControl.snp.bottom)
      make.left.right.equalTo(self.view)
      make.bottom.equalTo(self.view.safeArea.bottom)
    }

    self.containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.recentView.view.snp.makeConstraints { make in
      make.top.left.equalTo(self.containerView)
    }
    
    self.popularView.view.snp.makeConstraints { make in
      make.top.bottom.right.equalTo(self.containerView)
      make.left.equalTo(self.recentView.view.snp.right)
    }
    
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
   
    self.recentView.view.snp.makeConstraints { make in
      make.width.equalTo(self.view.frame.width)
      make.height.equalTo(self.scrollView.frame.height)
    }
    
    self.popularView.view.snp.makeConstraints { make in
      make.width.equalTo(self.view.frame.width)
      make.height.equalTo(self.scrollView.frame.height)
    }
    
    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width * 2, height: self.scrollView.frame.height)
  }
  
  // MARK: - -> Rx Event Binding
  
  func setupEventBinding() {
    
    self.addButton.rx.tap
      .debounce(0.3, scheduler: MainScheduler.instance)
      .bind(to: viewModel.didTappedAddButton)
      .disposed(by: disposeBag)
    
    self.segmentedControl.rx.selectedSegmentIndex
      .bind(to: viewModel.selectedSegmentIndex)
      .disposed(by: disposeBag)
    
    self.scrollView.rx.contentOffset
      .map { [weak self] in
        Int($0.x / (self?.view.bounds.width)!)
      }
      .distinctUntilChanged()
      .bind(to: viewModel.swipePage)
      .disposed(by: disposeBag)
  }
  
  // MARK: - <- Rx UI Binding
  
  func setupUIBinding() {
    
    viewModel.add
      .drive(onNext: { [weak self] in
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        
        var configure = TLPhotosPickerConfigure()
        configure.doneTitle = "Done".localized
        configure.cancelTitle = "Cancel".localized
        configure.defaultCameraRollTitle = "All Photos".localized
        configure.allowedVideo = false
        configure.selectedColor = .tintColor
        viewController.configure = configure
        
        self?.present(viewController, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    viewModel.showView
      .drive(onNext: { [weak self] index in
        let width = (self?.view.bounds.width)! * CGFloat(index)
        
        self?.scrollView.setContentOffset(CGPoint(x: width, y: 0), animated: true)
        self?.segmentedControl.selectedSegmentIndex = index
      })
      .disposed(by: disposeBag)
    
  }
  
  private func add(_ viewControllers: [UIViewController], to containerView: UIView) {
    
    for vc in viewControllers {
      containerView.addSubview(vc.view)
      self.addChild(vc)
      vc.didMove(toParent: self)
    }
  }
  
}


extension SuggestedViewController: TLPhotosPickerViewControllerDelegate {
  //TLPhotosPickerViewControllerDelegate
  func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
    // use selected order, fullresolution image
    log.verbose(withTLPHAssets)
  }
  func dismissPhotoPicker(withPHAssets: [PHAsset]) {
    log.verbose(withPHAssets)
    // if you want to used phasset.
  }
  func photoPickerDidCancel() {
    log.verbose("did cancel")
    // cancel
  }
  func dismissComplete() {
    log.verbose("completed")
    // picker viewcontroller dismiss completion
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
    log.verbose("album denied")
    // handle denied albums permissions case
  }
  func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
    log.verbose("camera denied")
    // handle denied camera permissions case
  }
}
