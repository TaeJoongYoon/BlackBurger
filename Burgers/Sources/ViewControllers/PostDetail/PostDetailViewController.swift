//
//  PostDetailViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 24/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import Cosmos
import FirebaseAuth
import ReusableKit
import RxCocoa
import RxGesture
import RxSwift

final class PostDetailViewController: BaseViewController, ViewType {
  
  // MARK: Constants
  
  struct Reusable {
    static let detailCell = ReusableCell<DetailCell>()
  }
  
  struct Constant {
    
  }
  
  struct Metric {
    static let borderWidth = Double(2)
    static let collectionWidth = UIScreen.main.bounds.width
    static let collectionHeight = UIScreen.main.bounds.width / 1.5
    static let offset = 20
    static let starSize = Double(UIScreen.main.bounds.size.width / 12)
  }
  
  // MARK: Properties
  
  var viewModel: PostDetailViewModelType!
  var post: Post!
  var isLiked = BehaviorRelay<Bool>(value: false)
  
  // MARK: UI
  
  let moreButton = UIBarButtonItem().then {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "more.png"), for: .normal)
    $0.customView = button
  }
  
  let imageCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()).then {
      $0.backgroundColor = .white
      $0.isPagingEnabled = true
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.register(Reusable.detailCell)
  }
  
  let pageControl = UIPageControl(frame: .zero).then {
    $0.numberOfPages = 1
    $0.currentPage = 0
    $0.pageIndicatorTintColor = .lightGray
    $0.currentPageIndicatorTintColor = .tintColor
  }
  
  let ratingView = CosmosView(frame: .zero).then {
    $0.rating = 0
    $0.settings.updateOnTouch = false
    $0.settings.fillMode = .precise
    $0.settings.filledColor = .tintColor
    $0.settings.emptyBorderColor = .tintColor
    $0.settings.filledBorderColor = .tintColor
    $0.settings.emptyBorderWidth = Metric.borderWidth
    $0.settings.starSize = Metric.starSize
  }
  
  let likeImageView = UIImageView(frame: .zero)
  
  let likesCountLabel = UILabel(frame: .zero).then {
    $0.textColor = .black
  }
  
  let contentTextView = UITextView(frame: .zero).then {
    $0.isEditable = false
    $0.isScrollEnabled = true
    $0.textColor = .black
    $0.font = UIFont.preferredFont(forTextStyle: .body)
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.autocorrectionType = .no
    $0.autocapitalizationType = .none
  }
  
  // MARK: Setup UI
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "DETAIL".localized
    self.view.backgroundColor = .white
    
    self.navigationItem.rightBarButtonItem = self.moreButton
    
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    layout.sectionInset = UIEdgeInsets.zero
    layout.footerReferenceSize = CGSize.zero
    layout.headerReferenceSize = CGSize.zero
    self.imageCollectionView.collectionViewLayout = layout
    
    self.view.addSubview(self.imageCollectionView)
    self.view.addSubview(self.pageControl)
    self.view.addSubview(self.ratingView)
    self.view.addSubview(self.likeImageView)
    self.view.addSubview(self.likesCountLabel)
    self.view.addSubview(self.contentTextView)
  }
  
  // MARK: Setup Constraints
  
  override func setupConstraints() {
    
    self.imageCollectionView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeArea.top)
      make.left.right.equalToSuperview()
      make.height.equalTo(Metric.collectionHeight)
    }
    
    self.pageControl.snp.makeConstraints { make in
      make.top.equalTo(self.imageCollectionView.snp.bottom).offset(Metric.offset/2)
      make.centerX.equalToSuperview()
    }
    
    self.ratingView.snp.makeConstraints { make in
      make.top.equalTo(self.pageControl.snp.bottom).offset(Metric.offset/2)
      make.left.equalTo(self.view).offset(Metric.offset)
      make.height.equalTo(Metric.starSize)
    }
    
    self.likeImageView.snp.makeConstraints { make in
      make.top.equalTo(self.ratingView.snp.bottom).offset(Metric.offset/2)
      make.left.equalTo(self.view).offset(Metric.offset)
    }
    
    self.likesCountLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.likeImageView)
      make.left.equalTo(self.likeImageView.snp.right).offset(Metric.offset)
    }
    
    self.contentTextView.snp.makeConstraints { make in
      make.top.equalTo(self.likeImageView.snp.bottom).offset(Metric.offset/2)
      make.left.right.equalTo(self.view).inset(Metric.offset)
      make.bottom.equalTo(self.view.safeArea.bottom)
    }
    
  }
  
  // MARK: - -> Rx Event Binding
  
  func setupEventBinding() {
    
    self.rx.viewWillAppear
      .map { [weak self] in
        (self?.post.id)!
      }
      .bind(to: viewModel.viewWillAppear)
      .disposed(by: self.disposeBag)
    
    self.imageCollectionView.rx.currentPage
      .bind(to: viewModel.willDisplayCell)
      .disposed(by: self.disposeBag)
    
    Observable.merge([
      self.imageCollectionView.rx.tapGesture() { gesture, _ in
        gesture.numberOfTapsRequired = 2
        }
        .when(.recognized)
        .asObservable(),
      self.likeImageView.rx.tapGesture()
        .when(.recognized)
        .asObservable()])
        .map { [weak self] _ in
          ((self?.post.id)!, (self?.isLiked.value)!)
        }
        .bind(to: viewModel.requestLike)
        .disposed(by: self.disposeBag)
    
  }
  
  // MARK: - <- Rx UI Binding
  
  func setupUIBinding() {
    
    self.imageCollectionView.rx.setDelegate(self)
      .disposed(by: self.disposeBag)
    
    viewModel.setView
      .drive(onNext: { [weak self] in
        self?.setView($0)
      })
      .disposed(by: self.disposeBag)
    
    viewModel.currentPage
      .drive(onNext: { [weak self] in
        self?.setPageControl($0)
      })
      .disposed(by: self.disposeBag)
    
    viewModel.liked
      .drive(onNext: { [weak self] in
        self?.likesCountLabel.text = String($0)
        var toggle = (self?.isLiked.value)!
        toggle.toggle()
        self?.isLiked.accept(toggle)
      })
      .disposed(by: self.disposeBag)
    
    self.isLiked.asObservable()
      .subscribe(onNext: { [weak self] in
        if $0 {
          self?.likeImageView.image = UIImage(named: "thumbs-up.png")
        } else {
          self?.likeImageView.image = UIImage(named: "no-thumbs-up.png")
        }
      })
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: Action Handler
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }
  
  private func setView(_ post: Post) {
    self.post = post
    
    self.imageCollectionView.dataSource = nil
    Observable.just(post)
      .map { $0.imageURLs }
      .bind(to: self.imageCollectionView.rx.items(
        cellIdentifier: Reusable.detailCell.identifier,
        cellType: DetailCell.self)
      ) { row, element, cell in
        cell.configureWith(url: element)
      }
      .disposed(by: self.disposeBag)
    
    self.pageControl.numberOfPages = self.post.imageURLs.count
    
    self.ratingView.rating = self.post.rating
    self.isLiked.accept(self.post!.likeUser.contains((Auth.auth().currentUser?.email)!))
    
    self.likesCountLabel.text = String(self.post.likes)
    self.contentTextView.text = self.post.content
  }
  
  private func setPageControl(_ currentPage: Int) {
    self.pageControl.currentPage = currentPage
    self.pageControl.updateCurrentPageDisplay()
  }
  
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PostDetailViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    return CGSize(width: Metric.collectionWidth, height: Metric.collectionHeight)
  }
  
}
