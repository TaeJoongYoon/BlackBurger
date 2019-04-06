//
//  SuggestedTableViewCell.swift
//  Burgers
//
//  Created by Tae joong Yoon on 02/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import Cosmos
import SnapKit
import Then
import UIKit

class BurgerPostCell: UITableViewCell {
  
  // MARK: - UI Metrics
  
  private struct UI {
    static let mainFontSize = CGFloat(17)
    static let subFontSize = CGFloat(12)
    static let offset = 10
  }
  
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
  
  private let restaurantLabel = UILabel(frame: .zero).then {
    $0.textColor = .black
    $0.font = UIFont.boldSystemFont(ofSize: UI.mainFontSize)
    $0.lineBreakMode = .byTruncatingTail
  }
  
  private let addressLabel = UILabel(frame: .zero).then {
    $0.textColor = .lightGray
    $0.font = $0.font.withSize(UI.subFontSize)
    $0.lineBreakMode = .byTruncatingTail
  }
  
  private let likeImage = UIImageView(frame: .zero).then {
    $0.image = UIImage(named: "thumbs-up.png")
  }
  
  private let likes = UILabel(frame: .zero).then {
    $0.textColor = .mainColor
    $0.lineBreakMode = .byTruncatingTail
  }
  
  private let rating = CosmosView(frame: .zero).then {
    $0.rating = 0
    $0.settings.updateOnTouch = true
    $0.settings.fillMode = .precise
    $0.settings.filledColor = .tintColor
    $0.settings.emptyBorderColor = .tintColor
    $0.settings.filledBorderColor = .tintColor
    $0.settings.emptyBorderWidth = 1.0
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
    self.rating.settings.starSize = Double(UIScreen.main.bounds.size.width / 20)
    
    contentView.addSubview(self.mainImageView)
    contentView.addSubview(self.rating)
   
    self.containerView.addSubview(self.restaurantLabel)
    self.containerView.addSubview(self.addressLabel)
    self.containerView.addSubview(self.likes)
    self.containerView.addSubview(self.placeImage)
    self.containerView.addSubview(self.likeImage)
    
    contentView.addSubview(self.containerView)
  }
  
  
  private func setupConstraints() {
  
    self.mainImageView.snp.makeConstraints { make in
      make.top.left.right.equalToSuperview()
      make.height.equalTo(160)
      make.bottom.equalTo(self.containerView.snp.top)
    }
    
    self.rating.snp.makeConstraints { make in
      make.top.equalTo(self.contentView).offset(UI.offset)
      make.right.equalTo(self.contentView).offset(-UI.offset)
    }
    
    self.containerView.snp.makeConstraints { make in
      make.top.equalTo(self.mainImageView.snp.bottom)
      make.left.right.bottom.equalToSuperview()
    }
    
    self.placeImage.snp.makeConstraints { make in
      make.top.equalTo(self.mainImageView.snp.bottom).offset(UI.offset)
      make.left.equalTo(self.contentView).offset(UI.offset)
    }
    
    self.restaurantLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.placeImage.snp.centerY)
      make.left.equalTo(self.placeImage.snp.right).offset(UI.offset)
      make.width.equalTo(self.containerView.snp.width).multipliedBy(0.5)
    }
    
    self.addressLabel.snp.makeConstraints { make in
      make.top.equalTo(self.restaurantLabel.snp.bottom).offset(UI.offset/2)
      make.left.equalTo(self.contentView).offset(UI.offset)
      make.width.equalTo(self.containerView.snp.width).multipliedBy(0.7)
    }
    
    self.likeImage.snp.makeConstraints { make in
      make.centerY.equalTo(self.containerView.snp.centerY)
      make.right.equalTo(self.likes.snp.left).offset(-UI.offset)
    }
    
    self.likes.snp.makeConstraints { make in
      make.centerY.equalTo(containerView.snp.centerY)
      make.right.equalTo(self.contentView).offset(-UI.offset)
    }
    
  }
  
  // MARK: - Cell Contents
  
  func configureWith(url: String, restaurant: String, address: String, likes: Int, rating: Double) {
    self.mainImageView.kf.setImage(with: URL(string: url))
    self.restaurantLabel.text = restaurant
    self.addressLabel.text = address
    self.likes.text = String(likes)
    self.rating.rating = rating
  }
}
