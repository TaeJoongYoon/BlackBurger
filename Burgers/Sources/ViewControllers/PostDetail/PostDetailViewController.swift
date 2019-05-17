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
import Toaster

final class PostDetailViewController: BaseViewController {
  
  // MARK: Constants
  
  fileprivate struct Reusable {
    static let detailCell = ReusableCell<DetailCell>()
  }
  
  fileprivate struct Metric {
    static let borderWidth = Double(2)
    static let collectionWidth = UIScreen.main.bounds.width
    static let collectionHeight = UIScreen.main.bounds.width / 1.5
    static let offset = 20
    static let starSize = Double(UIScreen.main.bounds.size.width / 12)
  }
  
  // MARK: Properties
  
  fileprivate let viewModel: PostDetailViewModelType
  fileprivate var post: Post
  fileprivate let isLiked = BehaviorRelay<Bool>(value: false)
  
  // MARK: UI
  
  let moreButton = UIBarButtonItem(
    image: UIImage(named: "more.png"),
    style: .plain,
    target: self,
    action: nil
  )
  
  let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil).then {
    $0.tintColor = .tintColor
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
  
  // MARK: Initalize
  
  init(
    viewModel: PostDetailViewModelType,
    post: Post
    ) {
    self.viewModel = viewModel
    self.post = post
    super.init()
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
  
  override func bindingEvent() {
    
    self.rx.viewWillAppear
      .map { [weak self] in
        (self?.post.id)!
      }
      .bind(to: viewModel.inputs.viewWillAppear)
      .disposed(by: self.disposeBag)
    
    viewModel.inputs.id.accept(self.post.id)
    
    self.imageCollectionView.rx.currentPage
      .bind(to: viewModel.inputs.willDisplayCell)
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
      .bind(to: viewModel.inputs.requestLike)
      .disposed(by: self.disposeBag)
    
    self.contentTextView.rx.text
      .orEmpty
      .distinctUntilChanged()
      .bind(to: viewModel.inputs.text)
      .disposed(by: self.disposeBag)
    
    self.moreButton.rx.tap
      .bind(to: viewModel.inputs.moreButtonDidTapped)
      .disposed(by: self.disposeBag)
    
    self.doneButton.rx.tap
      .bind(to: viewModel.inputs.doneButtonDidTapped)
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - <- Rx UI Binding
  
  override func bindingUI() {
    
    self.imageCollectionView.rx.setDelegate(self)
      .disposed(by: self.disposeBag)
    
    viewModel.outputs.setView
      .drive(onNext: { [weak self] post in
        self?.setView(post)
      })
      .disposed(by: self.disposeBag)
    
    viewModel.outputs.currentPage
      .drive(onNext: { [weak self] in
        self?.setPageControl($0)
      })
      .disposed(by: self.disposeBag)
    
    viewModel.outputs.liked
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
    
    viewModel.outputs.actionSheet
      .drive(onNext: { [weak self] in
        self?.actionSheet()
      })
      .disposed(by: self.disposeBag)
    
    viewModel.outputs.edit
      .drive(onNext: { [weak self] in
        self?.edit($0)
      })
      .disposed(by: self.disposeBag)
    
    viewModel.outputs.deleted
      .drive(onNext: { [weak self] in
        self?.deleted($0)
      })
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: Action Handler
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }
  
  private func setView(_ post: Post) {
    self.imageCollectionView.dataSource = nil
    self.post = post
    
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
    self.isLiked.accept(self.post.likeUser.contains((Auth.auth().currentUser?.uid)!))
    
    self.likesCountLabel.text = String(self.post.likes)
    self.contentTextView.text = self.post.content
  }
  
  private func setPageControl(_ currentPage: Int) {
    self.pageControl.currentPage = currentPage
    self.pageControl.updateCurrentPageDisplay()
  }
  
  private func actionSheet() {
    let alertController = UIAlertController(
      title: nil,
      message: nil,
      preferredStyle: .actionSheet
    )
    
    let saveImagesButton = UIAlertAction(
      title: "Save Images".localized,
      style: .default
    ) { _ in
      let downloadGroup = DispatchGroup()
      let _ = DispatchQueue.global(qos: .userInitiated)
      DispatchQueue.concurrentPerform(iterations: self.post.imageURLs.count) { index in
        let string = self.post.imageURLs[index]
        let url = URL(string: string)!
        downloadGroup.enter()
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
          guard let data = data else { return }
          let image = UIImage(data: data)!
          DispatchQueue.main.async {
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            downloadGroup.leave()
          }
        }
        dataTask.resume()
      }
      downloadGroup.notify(queue: DispatchQueue.main) {
        Toast(text: "Saved Images!".localized, duration: Delay.long).show()
      }
    }
    
    let sendButton = UIAlertAction(
      title: "Edit".localized,
      style: .default
    ) { _ in
      self.contentTextView.snp.remakeConstraints { make in
        make.top.equalTo(self.view.safeArea.top).offset(Metric.offset)
        make.left.right.equalTo(self.view).inset(Metric.offset)
        make.bottom.equalTo(self.view.safeArea.bottom)
      }
      self.view.subviews.forEach { $0.isHidden = true }
      self.contentTextView.isHidden = false
      self.contentTextView.isEditable = true
      self.contentTextView.becomeFirstResponder()
      self.navigationItem.rightBarButtonItem = self.doneButton
    }
    
    let deleteButton = UIAlertAction(
      title: "Delete".localized,
      style: .destructive
    ) { _ in
      self.viewModel.inputs.requestDelete(id: self.post.id)
    }
    
    let cancelButton = UIAlertAction(
      title: "Cancel".localized,
      style: .cancel,
      handler: nil
    )
    
    alertController.addAction(saveImagesButton)
    if post.author == Auth.auth().currentUser?.uid {
      alertController.addAction(sendButton)
      alertController.addAction(deleteButton)
    }
    alertController.addAction(cancelButton)
    
    self.present(alertController, animated: true, completion: nil)
  }
  
  private func edit(_ isEdited: Bool) {
    if isEdited {
      self.view.subviews.forEach { $0.isHidden = false }
      self.contentTextView.snp.remakeConstraints { make in
        make.top.equalTo(self.likeImageView.snp.bottom).offset(Metric.offset/2)
        make.left.right.equalTo(self.view).inset(Metric.offset)
        make.bottom.equalTo(self.view.safeArea.bottom)
      }
      self.contentTextView.isEditable = false
      self.navigationItem.rightBarButtonItem = self.moreButton
    } else {
      Toast(text: "Failure Edit!".localized, duration: Delay.long).show()
    }
  }
  
  private func deleted(_ isDeleted: Bool) {
    if isDeleted {
      self.navigationController?.popViewController(animated: true) {
        Toast(text: "Success Delete!".localized, duration: Delay.long).show()
      }
    } else {
      Toast(text: "Failure Delete!".localized, duration: Delay.long).show()
    }
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
