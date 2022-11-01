//
//  FoodtruckTableViewCell.swift
//  Food Truck Finder
//
//  Created by Charles Romeo on 2/11/20.
//  Copyright © 2020 Adrenaline Life. All rights reserved.
//

import UIKit

class FoodtruckTableViewCell: UITableViewCell {

    @IBOutlet weak var lblSpotLocationName: UILabel!
    @IBOutlet weak var lblSpotDate: UILabel!
    @IBOutlet weak var lblEstPeople: UILabel!
    @IBOutlet weak var lblCost: UILabel!
    @IBOutlet weak var insideView: UIView!
    @IBOutlet weak var bgView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        
    }
    
    func setupTableCell(spot:Spot) {
        
        insideView.fMainTableCellShadowDesign()
        bgView.fMainTableCellBackgroundDesign()
        lblSpotLocationName?.setTitleAndImage(text: spot.locationName!, leftIcon:  UIImage(named:"f_spot_two_dark.png")?.resizeImage(scale: 0.25), rightIcon: nil)
        guard let estPeople = spot.estPeople else { return }
        lblEstPeople?.setTitleAndImage(text: estPeople, leftIcon:
            UIImage(named:"f_people_dark.png")?.resizeImage(scale: 0.25), rightIcon: nil)
        guard let price = spot.price else { return }
        lblCost?.setPriceWithImage(text: price, leftIcon:
            UIImage(named:"f_calculator_dark.png")?.resizeImage(scale: 0.25), rightIcon: nil)
        guard let date = spot.date else { return }
        guard let mealTime = spot.mealTime else {
            //SETUP DATE WITHOUT MEALTIME JUST AS BACKUP!!
            return
        }
        lblSpotDate.setTitleAndImage(text: DateUtils().getFDate(date: date, mealTime: mealTime), leftIcon: UIImage(named:"f_clock_dark.png")?.resizeImage(scale: 0.25), rightIcon: nil)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
