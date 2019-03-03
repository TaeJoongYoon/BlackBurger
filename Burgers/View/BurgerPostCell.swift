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
  
  private let label = UILabel(frame: .zero).then {
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
  
  private func setupUI() {
    self.contentView.backgroundColor = .white
    contentView.addSubview(label)
  }
  
  private func setupConstraints() {
    label.snp.makeConstraints { make in
      make.center.equalTo(self.contentView)
    }
  }
  
  // MARK: - Cell Contents
  
  func configureWith(name: String) {
    label.text = name
  }
}
