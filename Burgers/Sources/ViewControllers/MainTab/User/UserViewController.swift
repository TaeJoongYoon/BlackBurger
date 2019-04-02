//
//  UserViewController.swift
//  Burgers
//
//  Created by Tae joong Yoon on 25/02/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import FirebaseAuth
import PMAlertController
import RxCocoa
import RxSwift
import Toaster

final class UserViewController: BaseViewController, ViewType {
  
  // MARK: Constants
  
  struct Metric {
    static let idFontSize = CGFloat(22)
    static let itemFontSize = CGFloat(16)
    static let buttonTitleInset = CGFloat(20)
    static let buttonWidthRatio = CGFloat(0.8)
    static let offset = CGFloat(30)
  }
  
  // MARK: Properties
  
  var viewModel: UserViewModelType!
  
  // MARK: UI
  
  let idLabel = UILabel(frame: .zero).then {
    $0.font = UIFont.boldSystemFont(ofSize: Metric.idFontSize)
  }
  
  let myPostButton = UIButton(type: .system).then {
    $0.setImage(UIImage(named:"posting.png"), for: .normal)
    $0.tintColor = .tintColor
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: Metric.buttonTitleInset, bottom: 0, right: 0)
    $0.setTitle("My Posts".localized, for: .normal)
    $0.setTitleColor(.mainColor, for: .normal)
    $0.contentHorizontalAlignment = .left
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: Metric.itemFontSize)
  }
  
  let myLikeButton = UIButton(type: .system).then {
    $0.setImage(UIImage(named:"thumbs-up.png"), for: .normal)
    $0.tintColor = .tintColor
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: Metric.buttonTitleInset, bottom: 0, right: 0)
    $0.setTitle("My Likes".localized, for: .normal)
    $0.setTitleColor(.mainColor, for: .normal)
    $0.contentHorizontalAlignment = .left
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: Metric.itemFontSize)
  }
  
  let changePasswordButton = UIButton(type: .system).then {
    $0.setImage(UIImage(named:"password.png"), for: .normal)
    $0.tintColor = .tintColor
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: Metric.buttonTitleInset, bottom: 0, right: 0)
    $0.setTitle("Change Password".localized, for: .normal)
    $0.setTitleColor(.mainColor, for: .normal)
    $0.contentHorizontalAlignment = .left
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: Metric.itemFontSize)
  }
  
  let termsButton = UIButton(type: .system).then {
    $0.setImage(UIImage(named:"terms.png"), for: .normal)
    $0.tintColor = .tintColor
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: Metric.buttonTitleInset, bottom: 0, right: 0)
    $0.setTitle("Terms of service".localized, for: .normal)
    $0.setTitleColor(.mainColor, for: .normal)
    $0.contentHorizontalAlignment = .left
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: Metric.itemFontSize)
  }
  
  let privacyButton = UIButton(type: .system).then {
    $0.setImage(UIImage(named:"terms.png"), for: .normal)
    $0.tintColor = .tintColor
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: Metric.buttonTitleInset, bottom: 0, right: 0)
    $0.setTitle("Privacy Policy".localized, for: .normal)
    $0.setTitleColor(.mainColor, for: .normal)
    $0.contentHorizontalAlignment = .left
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: Metric.itemFontSize)
  }
  
  let logoutButton = UIButton(type: .system).then {
    $0.setImage(UIImage(named:"logout.png"), for: .normal)
    $0.tintColor = .tintColor
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: Metric.buttonTitleInset, bottom: 0, right: 0)
    $0.setTitle("Logout".localized, for: .normal)
    $0.setTitleColor(.mainColor, for: .normal)
    $0.contentHorizontalAlignment = .left
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: Metric.itemFontSize)
  }
  
  let accountRemoveButton = UIButton(type: .system).then {
    $0.setImage(UIImage(named:"remove.png"), for: .normal)
    $0.tintColor = .red
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: Metric.buttonTitleInset, bottom: 0, right: 0)
    $0.setTitle("Account Remove".localized, for: .normal)
    $0.setTitleColor(.red, for: .normal)
    $0.contentHorizontalAlignment = .left
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: Metric.itemFontSize)
  }
  
  
  // MARK: Setup UI
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "USER".localized
    self.view.backgroundColor = .white
    
    let backBarButtton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    self.navigationItem.backBarButtonItem = backBarButtton
    
    self.tabBarItem.image = UIImage(named: "user-unselected.png")
    self.tabBarItem.selectedImage = UIImage(named: "user-selected.png")
    
    self.view.addSubview(self.idLabel)
    self.view.addSubview(self.myPostButton)
    self.view.addSubview(self.myLikeButton)
    self.view.addSubview(self.changePasswordButton)
    self.view.addSubview(self.termsButton)
    self.view.addSubview(self.privacyButton)
    self.view.addSubview(self.logoutButton)
    self.view.addSubview(self.accountRemoveButton)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.idLabel.text = (Auth.auth().currentUser?.email)!
  }
  
  // MARK: Setup Constraints
  
  override func setupConstraints() {
    
    self.idLabel.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeArea.top).offset(Metric.offset)
      make.left.equalTo(self.view).offset(Metric.offset)
    }
    
    self.myPostButton.snp.makeConstraints { make in
      make.top.equalTo(self.idLabel.snp.bottom).offset(Metric.offset*2)
      make.left.equalTo(self.view).offset(Metric.offset)
      make.width.equalTo(self.view).multipliedBy(Metric.buttonWidthRatio)
    }
    
    self.myLikeButton.snp.makeConstraints { make in
      make.top.equalTo(self.myPostButton.snp.bottom).offset(Metric.offset)
      make.left.equalTo(self.view).offset(Metric.offset)
      make.width.equalTo(self.view).multipliedBy(Metric.buttonWidthRatio)
    }
    
    self.changePasswordButton.snp.makeConstraints { make in
      make.top.equalTo(self.myLikeButton.snp.bottom).offset(Metric.offset)
      make.left.equalTo(self.view).offset(Metric.offset)
      make.width.equalTo(self.view).multipliedBy(Metric.buttonWidthRatio)
    }
    
    self.termsButton.snp.makeConstraints { make in
      make.top.equalTo(self.changePasswordButton.snp.bottom).offset(Metric.offset)
      make.left.equalTo(self.view).offset(Metric.offset)
      make.width.equalTo(self.view).multipliedBy(Metric.buttonWidthRatio)
    }
    
    self.privacyButton.snp.makeConstraints { make in
      make.top.equalTo(self.termsButton.snp.bottom).offset(Metric.offset)
      make.left.equalTo(self.view).offset(Metric.offset)
      make.width.equalTo(self.view).multipliedBy(Metric.buttonWidthRatio)
    }
    
    self.logoutButton.snp.makeConstraints { make in
      make.top.equalTo(self.privacyButton.snp.bottom).offset(Metric.offset)
      make.left.equalTo(self.view).offset(Metric.offset)
      make.width.equalTo(self.view).multipliedBy(Metric.buttonWidthRatio)
    }
    
    self.accountRemoveButton.snp.makeConstraints { make in
      make.top.equalTo(self.logoutButton.snp.bottom).offset(Metric.offset)
      make.left.equalTo(self.view).offset(Metric.offset)
      make.width.equalTo(self.view).multipliedBy(Metric.buttonWidthRatio)
    }
    
  }
  
  // MARK: - -> Rx Event Binding
  
  func setupEventBinding() {
    
    self.myPostButton.rx.tap
      .debounce(0.3, scheduler: MainScheduler.instance)
      .bind(to: viewModel.myPostButtonDidTapped)
      .disposed(by: self.disposeBag)
    
    self.myLikeButton.rx.tap
      .debounce(0.3, scheduler: MainScheduler.instance)
      .bind(to: viewModel.myLikeButtonDidTapped)
      .disposed(by: self.disposeBag)
    
    self.changePasswordButton.rx.tap
      .debounce(0.3, scheduler: MainScheduler.instance)
      .bind(to: viewModel.changePasswordButtonDidTapped)
      .disposed(by: self.disposeBag)
    
    self.termsButton.rx.tap
      .debounce(0.3, scheduler: MainScheduler.instance)
      .bind(to: viewModel.termsButtonDidTapped)
      .disposed(by: self.disposeBag)
    
    self.privacyButton.rx.tap
      .debounce(0.3, scheduler: MainScheduler.instance)
      .bind(to: viewModel.privacyButtonDidTapped)
      .disposed(by: self.disposeBag)
    
    self.logoutButton.rx.tap
      .debounce(0.3, scheduler: MainScheduler.instance)
      .bind(to: viewModel.logoutButtonDidTapped)
      .disposed(by: self.disposeBag)
    
    self.accountRemoveButton.rx.tap
      .debounce(0.3, scheduler: MainScheduler.instance)
      .bind(to: viewModel.accountRemoveButtonDidTapped)
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: - <- Rx UI Binding
  
  func setupUIBinding() {
    
    viewModel.post
      .drive(onNext: { [weak self] in
        self?.posts()
      })
      .disposed(by: self.disposeBag)
    
    viewModel.like
      .drive(onNext: { [weak self] in
        self?.likes()
      })
      .disposed(by: self.disposeBag)
    
    viewModel.changePassword
      .drive(onNext: { [weak self] in
        self?.changePassword()
      })
      .disposed(by: self.disposeBag)
    
    viewModel.passwordChanged
      .drive(onNext: {
        if $0 {
          Toast(text: "Success Changing".localized, duration: Delay.long).show()
        } else {
          Toast(text: "Failure Changing".localized, duration: Delay.long).show()
        }
      })
      .disposed(by: self.disposeBag)
    
    viewModel.terms
      .drive(onNext: { [weak self] in
        self?.terms()
      })
      .disposed(by: self.disposeBag)
    
    viewModel.privacy
      .drive(onNext: { [weak self] in
        self?.privacy()
      })
      .disposed(by: self.disposeBag)
    
    viewModel.logout
      .drive(onNext: { [weak self] in
        if $0 {
          self?.logout()
        } else {
          Toast(text: "Server Error".localized, duration: Delay.long).show()
        }
      })
      .disposed(by: self.disposeBag)
    
    viewModel.accountRemove
      .drive(onNext: { [weak self] in
        self?.accountRemove()
      })
      .disposed(by: self.disposeBag)
    
    viewModel.accountRemoved
      .drive(onNext: { [weak self] in
        if $0 {
          self?.logout()
        } else {
          Toast(text: "Server Error".localized, duration: Delay.long).show()
        }
      })
      .disposed(by: self.disposeBag)
    
  }
  
  // MARK: Action Handler
  
  private func posts() {
    let viewModel = PostListViewModel()
    let viewController = PostListViewController.create(with: viewModel)
    viewController.hidesBottomBarWhenPushed = true
    viewController.isMyList = true
    
    self.navigationController?.pushViewController(viewController, animated: true)
  }
  
  private func likes() {
    let viewModel = PostListViewModel()
    let viewController = PostListViewController.create(with: viewModel)
    viewController.hidesBottomBarWhenPushed = true
    viewController.isMyList = false
    
    self.navigationController?.pushViewController(viewController, animated: true)
  }
  
  private func changePassword() {
    
    let alertViewController = PMAlertController(title: "Change Password".localized,
                                                description: "Enter Your new Password".localized,
                                                image: nil,
                                                style: .alert)
    alertViewController.addTextField { (textField) in
      textField?.isSecureTextEntry = true
      textField?.returnKeyType = .done
      textField?.autocapitalizationType = .none
      textField?.placeholder = "password (more than 8)".localized
    }
    
    alertViewController.addAction(
      PMAlertAction(title: "OK".localized,
                    style: .default,
                    action: { () in
                      if let newPassword = alertViewController.textFields[0].text {
                        if newPassword.isValidPassword() {
                          Observable.just(newPassword)
                            .bind(to: self.viewModel.requestPasswordChange)
                            .disposed(by: self.disposeBag)
                        } else {
                          Toast(text: "Please type password more than 8".localized,
                                duration: Delay.long)
                            .show()
                        }
                      }
      }))
    
    alertViewController.addAction(PMAlertAction(title: "Cancel".localized,
                                                style: .cancel,
                                                action: nil))
    
    self.present(alertViewController, animated: true, completion: nil)
  }
  
  private func terms() {
    let viewController = TermsViewController()
    viewController.isTerms = true
    
    self.navigationController?.pushViewController(viewController, animated: true)
  }
  
  private func privacy() {
    let viewController = TermsViewController()
    viewController.isTerms = false
    
    self.navigationController?.pushViewController(viewController, animated: true)
  }
  
  private func logout() {
    let loginViewModel = LoginViewModel()
    let loginViewController = LoginViewController.create(with: loginViewModel)
    let navigationController = UINavigationController(rootViewController: loginViewController)
    navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController.navigationBar.clipsToBounds = true
    navigationController.navigationBar.tintColor = .tintColor
    
    Toast(text: "See you again :)".localized, duration: Delay.long).show()
    
    UIApplication.shared.keyWindow?
      .setRootViewController(navigationController,
                             options: UIWindow.TransitionOptions.init(
                              direction: .toTop,
                              style: .easeInOut))
  }
  
  private func accountRemove() {
    
    let alertViewController = PMAlertController(
      title: "Account Remove".localized,
      description: "Are you sure you want to delete your account?".localized,
      image: nil,
      style: .alert
    )
    
    alertViewController.addAction(PMAlertAction(title: "Cancel".localized,
                                                style: .cancel,
                                                action: nil))

    alertViewController.addAction(
      PMAlertAction(title: "OK".localized,
                    style: .default,
                    action: { () in
                      Observable.just(())
                        .bind(to: self.viewModel.requestRemove)
                        .disposed(by: self.disposeBag)
      }))
    
    self.present(alertViewController, animated: true, completion: nil)
  }
  
}