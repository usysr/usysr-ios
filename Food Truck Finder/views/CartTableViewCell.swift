//
//  CartTableViewCell.swift
//  Food Truck Finder
//
//  Created by Charles Romeo on 2/11/20.
//  Copyright © 2020 Adrenaline Life. All rights reserved.
//

import UIKit

class CartTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var lblSpotName: UILabel!
    @IBOutlet weak var lblSpotDate: UILabel!
    @IBOutlet weak var lblSpotCost: UILabel!
    @IBOutlet weak var imgItem: UIImageView!
    
    var spot : Spot = Spot()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgItem.image = UIImage(named: "f_spot_two_dark.png")
        cellView.fCartTableCellShadowDesign()
    }
    
//    func setupTableCellImage(spot:Spot) {
//        lblSpotName?.text = self.spot.locationName
//        imgItem.image = UIImage(named: "f_spot_two_dark.png")
//        guard let date = self.spot.date else { return }
//        guard let mealTime = self.spot.mealTime else { return }
//        guard let price = self.spot.price else { return }
//        lblSpotDate.text = date
//        lblSpotCost?.fPrice(price: price)
//        separatorInset = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
//    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
