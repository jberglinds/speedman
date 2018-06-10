//
//  TripUserActivityTableViewCell.swift
//  Studs
//
//  Created by Jonathan Berglind on 2018-06-10.
//  Copyright © 2018 Studieresan. All rights reserved.
//

import UIKit

class TripUserActivityTableViewCell: UITableViewCell {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var categoryButton: UIButton!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var peopleCountLabel: UILabel!
  var registerButtonTappedAction: (() -> Void)?

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }

  @IBAction func registerButtonTapped(_ sender: Any) {
    registerButtonTappedAction?()
  }
}
