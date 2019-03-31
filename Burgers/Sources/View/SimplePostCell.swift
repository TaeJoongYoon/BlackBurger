//
//  SimplePostCell.swift
//  Burgers
//
//  Created by Tae joong Yoon on 29/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import Cosmos
import SnapKit
import Then
import UIKit

class SimplePostCell: UITableViewCell {
  
  // MARK: - UI Metrics
  
  private struct UI {
    static let contentFontSize = CGFloat(12)
    static let offset = 20
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
  
  private let contentLabel = UILabel(frame: .zero).then {
    $0.font = UIFont.boldSystemFont(ofSize: UI.contentFontSize)
    $0.numberOfLines = 5
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
  
  private let likeImage = UIImageView(frame: .zero).then {
    $0.image = UIImage(named: "thumbs-up.png")
  }
  
  private let likes = UILabel(frame: .zero).then {
    $0.textColor = .mainColor
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
    
    self.containerView.addSubview(self.contentLabel)
    self.containerView.addSubview(self.rating)
    self.containerView.addSubview(self.likeImage)
    self.containerView.addSubview(self.likes)
    
    contentView.addSubview(self.containerView)
  }
  
  
  private func setupConstraints() {
    
    self.mainImageView.snp.makeConstraints { make in
      make.top.left.bottom.equalToSuperview()
      make.width.equalTo(130)
    }
    
    self.containerView.snp.makeConstraints { make in
      make.left.equalTo(self.mainImageView.snp.right)
      make.top.right.bottom.equalToSuperview()
    }
    
    self.contentLabel.snp.makeConstraints { make in
      make.left.equalTo(self.containerView).offset(UI.offset)
      make.top.equalTo(self.containerView).offset(UI.offset/2)
      make.width.equalTo(self.containerView.snp.width).multipliedBy(0.8)
    }
    
    self.rating.snp.makeConstraints { make in
      make.left.equalTo(self.containerView).offset(UI.offset)
      make.bottom.equalTo(self.containerView).offset(-UI.offset/2)
    }
    
    self.likeImage.snp.makeConstraints { make in
      make.bottom.equalTo(self.containerView).offset(-UI.offset/2)
      make.right.equalTo(self.likes.snp.left).offset(-UI.offset/4)
    }
    
    self.likes.snp.makeConstraints { make in
      make.bottom.equalTo(self.containerView).offset(-UI.offset/2)
      make.right.equalTo(self.containerView).offset(-UI.offset)
    }
    
  }
  
  // MARK: - Cell Contents
  
  func configureWith(url: String, content: String, rating: Double, likes: Int) {
    self.mainImageView.kf.setImage(with: URL(string: url))
    self.contentLabel.text = content
    self.rating.rating = rating
    self.likes.text = String(likes)
  }
}
