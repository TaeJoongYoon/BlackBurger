//
//  DetailCell.swift
//  Burgers
//
//  Created by Tae joong Yoon on 31/03/2019.
//  Copyright © 2019 Tae joong Yoon. All rights reserved.
//

import SnapKit
import Then
import UIKit

class DetailCell: BaseCollectionViewCell {
  
  // MARK: - Properties
  
  let detailImageView = UIImageView(frame: .zero).then {
    $0.backgroundColor = .white
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.clipsToBounds = true
    $0.contentMode = .scaleAspectFit
  }
  
  // MARK: - Initialize
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupUI()
    setupConstraints()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Setup UI
  
  private func setupUI() {
    self.contentView.backgroundColor = .white
    
    contentView.addSubview(self.detailImageView)
  }
  
  // MARK: Setup Constraints
  
  private func setupConstraints() {
    
    self.detailImageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  // MARK: - Cell Contents
  
  func configureWith(url: String) {
    self.detailImageView.kf.setImage(with: URL(string: url))
  }
}
