//
//  LocationTableViewCell.swift
//  Food Truck Finder
//
//  Created by Charles Romeo on 1/17/20.
//  Copyright © 2020 FoodTruck Finder. All rights reserved.
//

import UIKit
import FirebaseDatabase


class LocationTableViewCell: UITableViewCell {
    
    var location = Location()
    var user = User()
    var controller : LocManageViewController = LocManageViewController()
    var ref : DatabaseReference!

    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var lblLocationName: UILabel!
    @IBOutlet weak var lblAdressOne: UILabel!
    @IBOutlet weak var lblAddressTwo: UILabel!
    @IBOutlet weak var lblCityStateZip: UILabel!
    @IBOutlet weak var lblPeople: UILabel!
    @IBOutlet weak var btnRemoveRed: UIButton!
    @IBOutlet weak var btnEditRef: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnRemoveRed.addTarget(self, action: #selector(btnDoRemove(sender:)), for: .touchUpInside)
        btnEditRef.addTarget(self, action: #selector(btnDoEdit), for: .touchUpInside)
        //btnEditRef.visibility = .gone //hidden for selection of entire row instead
        viewMain.fCartTableCellShadowDesign()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell() {
        lblLocationName.text = location.locationName
        lblAdressOne.text = location.addressOne
        
        if location.addressTwo == "" {
            lblAddressTwo.visibility = .gone
        } else {
            lblAddressTwo.text = location.addressTwo
        }
    
        if location.estPeople == "" {
            lblPeople.visibility = .gone
        } else {
            lblPeople.text = "Est: \(location.estPeople!)"
        }
        
        guard let city = location.city else { return }
        guard let state = location.state else { return }
        guard let zip = location.zip else { return }
        lblCityStateZip.fCityStateZip(city: city, state: state, zip: zip)
    }
    
    @objc func btnDoRemove(sender: UIButton){
              
        let alert = UIAlertController(title: "Remove Location", message: "Would you like to delete this Location?", preferredStyle: .alert)
        let addEventAction = UIAlertAction(title: "Delete", style: .default, handler: { (action) -> Void in
           //Remove Location
           self.removeLocationFromFirebase()
           Session.removeAllLocationsFromSession()
           Session.removeRealmLocationObject()
           self.controller.reloadSession()
           self.controller.grabLocationsFromFirebase(user: self.user)
           print("Deleted!")
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(addEventAction)
        alert.addAction(cancelAction)
        controller.present(alert, animated: true, completion: nil)
    }
    
    @objc func btnDoEdit(sender: UIButton){
         
        //Set the id for firebase
        controller.originalLocationObject = location

        //put the contents of the location inside the text fields for edit
        controller.editLocName.text = location.locationName
        controller.editLocAddressOne.text = location.addressOne
        controller.editLocAddressTwo.text = location.addressTwo
        controller.editLocCity.text = location.city
        controller.editLocState.text = location.state
        controller.editLocZip.text = location.zip
        controller.editLocEstPeople.text = location.estPeople
        controller.editLocParkingInfo.text = location.details

        //setup buttons now
        controller.setEditMode()
    }
    
    //Remove location to Firebase for User
    func removeLocationFromFirebase(){
       //Save Profile
       ref = FireHelper.getLocationForUser(key: user.uid).child(location.id)
       ref.removeValue { error, _ in
           print(error as Any)
       }
      
    }
    
}
