//
//  SuggestedTableViewCell.swift
//  Burgers
//
//  Created by Tae joong Yoon on 02/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import SnapKit
import Then
import UIKit

class BurgerPostCell: UITableViewCell {
  
  // MARK: - Properties
  
  private let mainImageView = UIImageView(frame: .zero).then {
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.clipsToBounds = true
    $0.contentMode = .scaleAspectFill
  }
  
  private let containerView = UIView(frame: .zero).then {
    $0.backgroundColor = .white
  }
  
  private let placeImage = UIImageView(frame: .zero).then {
    $0.image = UIImage(named: "placeholder.png")
  }
  
  private let restaurant = UILabel(frame: .zero).then {
    $0.textColor = .mainColor
  }
  
  private let likeImage = UIImageView(frame: .zero).then {
    $0.image = UIImage(named: "thumbs-up.png")
  }
  
  private let likes = UILabel(frame: .zero).then {
    $0.textColor = .mainColor
  }
  
  // MARK: - UI Metrics
  
  private struct UI {
  }
  
  // MARK: - Initialize
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
    setupConstraints()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    layer.cornerRadius = 5.0
    layer.borderColor  =  UIColor.clear.cgColor
    layer.borderWidth = 1.0
    layer.shadowOpacity = 0.5
    layer.shadowColor =  UIColor.lightGray.cgColor
    layer.shadowRadius = 5.0
    layer.shadowOffset = CGSize(width:5, height: 5)
  }
  
  private func setupUI() {
    self.contentView.backgroundColor = .white
    contentView.addSubview(mainImageView)
   
    containerView.addSubview(restaurant)
    containerView.addSubview(likes)
    containerView.addSubview(placeImage)
    containerView.addSubview(likeImage)
    
    contentView.addSubview(containerView)
  }
  
  
  private func setupConstraints() {
    
    mainImageView.snp.makeConstraints { make in
      make.top.left.right.equalTo(self.contentView)
      make.height.equalTo(200)
      make.bottom.equalTo(self.containerView.snp.top)
    }
    
    containerView.snp.makeConstraints { make in
      make.top.equalTo(self.mainImageView.snp.bottom)
      make.left.right.bottom.equalTo(self.contentView)
    }
    
    placeImage.snp.makeConstraints { make in
      make.centerY.equalTo(containerView.snp.centerY)
      make.left.equalTo(self.contentView).offset(10)
    }
    
    restaurant.snp.makeConstraints { make in
      make.centerY.equalTo(containerView.snp.centerY)
      make.left.equalTo(self.placeImage.snp.right).offset(10)
    }
    
    likeImage.snp.makeConstraints { make in
      make.centerY.equalTo(containerView.snp.centerY)
      make.right.equalTo(self.likes.snp.left).offset(-10)
    }
    
    likes.snp.makeConstraints { make in
      make.centerY.equalTo(containerView.snp.centerY)
      make.right.equalTo(self.contentView).offset(-10)
    }
    
  }
  
  // MARK: - Cell Contents
  
  func configureWith(url: String, restaurant: String, likes: Int) {
    self.mainImageView.kf.setImage(with: URL(string: url))
    self.restaurant.text = restaurant
    self.likes.text = String(likes)
  }
}
