//
//  FoodTableViewCell.swift
//  Food Truck Finder
//
//  Created by Charles Romeo on 3/6/20.
//  Copyright © 2020 Adrenaline Life. All rights reserved.
//

import UIKit

class FoodTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var lblid: UILabel!
    @IBOutlet weak var lblSpotName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblCost: UILabel!
    @IBOutlet weak var insideView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //self.layer.borderWidth = 1
        
        // Configure the view for the selected state
    }
    
}
