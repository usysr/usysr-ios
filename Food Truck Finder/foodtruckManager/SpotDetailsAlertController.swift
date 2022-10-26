//
//  SpotDetailsAlertController.swift
//  Food Truck Finder
//
//  Created by Charles Romeo on 3/1/20.
//  Copyright © 2020 Food Truck Finder Bham. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import FirebaseDatabase

class SpotDetailsAlertController: UIViewController {

    var spot = Spot()
    var allSpots = List<Spot>()
    var user = User()
    var isAdd:Bool = false
    var isRemove:Bool = false
    
    var foodCartVC:FoodCartViewController?
    var foodCalendarVC:FoodCalendarViewController?
    
    @IBOutlet weak var bgBlur: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var mapView: UIView!
    
    @IBOutlet weak var lblLocationName: UILabel!
    @IBOutlet weak var lblLocationManager: UILabel!
    @IBOutlet weak var lblAddressOne: UILabel!
    @IBOutlet weak var lblAddressTwo: UILabel!
    @IBOutlet weak var lblCityStateZip: UILabel!
    @IBOutlet weak var lblParkingInfo: UITextView!
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTruckName: UILabel!   // Needs to be removed
    @IBOutlet weak var lblEstPeople: UILabel!
    @IBOutlet weak var lblFoodType: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var locationIcon: UIImageView!
    
    @IBAction func btnClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBOutlet weak var btnGenericRef: UIButton!
    @IBAction func btnGeneric(_ sender: Any) {
        
        if (isAdd) {
            //->Add Spot To Cart
            let alert = UIAlertController(title: "Add To Cart", message: "Would you like to add this spot to your cart?", preferredStyle: .alert)
            let addEventAction = UIAlertAction(title: "Add", style: .default, handler: { (action) -> Void in
                
                //Verify spot can be booked
                if self.spotPassedVerificationToBeBooked(spotToBook: self.spot) {
                    //->Add Spot To Cart
                    Session.addSpotToSession(spot: self.spot)
                    //->Set as Pending in Firebase
                    self.foodCalendarVC?.updateSpotAsPending(spot: self.spot)
                    print("Spot Added to Cart!")
                    self.dismiss(animated: true)
                }
                
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            alert.addAction(addEventAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
        } else {
            //Remove Spot Alert
            let alert = UIAlertController(title: "Remove", message: "Would you like to remove this spot from your cart?", preferredStyle: .alert)
            let addEventAction = UIAlertAction(title: "Remove", style: .default, handler: { (action) -> Void in
                //->Set as Available in Firebase
                self.foodCartVC?.updateSpotAsAvailable(spot: self.spot)
                print("Spot Removed from Cart!")
                self.dismiss(animated: true)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            alert.addAction(addEventAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        btnGenericRef.isHidden = true
        if let session = Session.getInstance(), let u = session.user {
            //Stay safe, stay here.
            self.user = u
            self.allSpots = session.spots
            print("No error!!")
        }else{
            dismiss(animated: true)
        }
        setupDisplay()
    }
    
    func setupDisplay() {
        
        setupBlur()
        
        if (self.isAdd) {
            setupAdd()
        } else if (self.isRemove) {
            setupRemove()
        }
        
        bgView.fSpotDetailsPopUpDesign()
        
        profileImageView.image = UIImage(named: "ProPicTransparent")!
        mapImage.image = UIImage(named: "map_comingsoon")!
        mapImage.layer.cornerRadius = 8
        
        if (self.spot.locationName!.isEmpty) { return }
        guard let city = self.spot.city else { return }
        guard let state  = self.spot.state else { return }
        guard let zip = self.spot.zip else { return }
        guard let date = self.spot.date else { return }
        
        lblLocationName.text = self.spot.locationName!
        lblLocationManager.fContact(contact: self.spot.spotManager!) //
        lblAddressOne.setTitleAndImage(text: self.spot.addressOne!, leftIcon:  UIImage(named:"f_spot_one_dark.png")?.resizeImage(scale: 0.25), rightIcon: nil)
        self.setupAddress(city: city, state: state, zip: zip)
        lblDate.setTitleAndImage(text: DateUtils().getFDate(date: date, mealTime: self.spot.mealTime!), leftIcon:  UIImage(named:"f_clock_dark.png")?.resizeImage(scale: 0.25), rightIcon: nil)
        
        if self.spot.assignedTruckName! != "" {
            lblTruckName.setTitleAndImage(text: self.spot.assignedTruckName!, leftIcon:  UIImage(named:"f_truck_dark.png")?.resizeImage(scale: 0.25), rightIcon: nil)
        } else {
            lblTruckName.setTitleAndImage(text: "None", leftIcon:  UIImage(named:"f_truck_dark.png")?.resizeImage(scale: 0.25), rightIcon: nil)
        }
        
        lblFoodType.text = self.spot.foodType
        
        lblParkingInfo.layer.borderWidth = 1
        lblParkingInfo.layer.borderColor = UIColor.black.cgColor
        lblParkingInfo.text = self.spot.parkingInfo
        
        guard let estPeople = self.spot.estPeople else { return }
        lblEstPeople?.setTitleAndImage(text: estPeople, leftIcon:
            UIImage(named:"f_people_dark.png")?.resizeImage(scale: 0.25), rightIcon: nil)
        guard let price = self.spot.price else { return }
        lblPrice?.setPriceWithImage(text: price, leftIcon:
            UIImage(named:"f_calculator_dark.png")?.resizeImage(scale: 0.25), rightIcon: nil)
    
    }
    
    func spotPassedVerificationToBeBooked(spotToBook:Spot) -> Bool {
        
        if !spotTimeHasNotBeenBooked(spotToBook: spotToBook) {
            //let user know they have already booked this time slot
            print("Denied Booking Due To Time Conflict")
            let alert = UIAlertController(title: "Date Conflict", message: "You have already booked this timeslot.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            return false
        }
        
        if hasBeenBookedTwiceInSameMonth(spotToBook: spotToBook) {
            //let user know they have reached their limit
            print("Denied Booking Due To Limit Conflict")
            let alert = UIAlertController(title: "Limit Conflict", message: "You have reached your limit of spots per location this month!", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    //TODO: Limit foodtrucks from booking more than 2 spots per location per month
    // 2 spots PER location PER month
    //-> check booked spots,
    //   -> if they have two from one location
    //   -> if both are the same month
    func hasBeenBookedTwiceInSameMonth(spotToBook:Spot) -> Bool {
        guard let tempDate = spotToBook.date else { return false } //Unwrap
        guard let toBookDbDate = DateUtils.convertStringToDateObjectForFirebaseDB(dateStr: tempDate) else { return false }
        let toBookMY = FireHelper.getSpotMonthYearForDBbyDate(date: toBookDbDate)
        var count = 0
        //Loop All Spots
        for spot in self.allSpots {
            //Verify Location Names Match First
            if spotToBook.locationName == spot.locationName {
                guard let spotDate = spot.date else { return false } //Unwrap
                guard let spotDbDate = DateUtils.convertStringToDateObjectForFirebaseDB(dateStr: spotDate) else { return false }
                let spotMY = FireHelper.getSpotMonthYearForDBbyDate(date: spotDbDate)
                //If their dates match, add to count
                if toBookMY == spotMY {
                    count += 1 //Add matches to count
                    if count == 2 { return true }
                }
            }
        }
        return false
    }
    
    func spotTimeHasNotBeenBooked(spotToBook:Spot) -> Bool {
        for spot in self.allSpots {
            if spot.date == spotToBook.date && spot.mealTime == spotToBook.mealTime
            {
                return false
            }
        }
        return true
    }
    
    func setupAddress(city: String, state: String, zip: String) {
        guard let addressTwo = self.spot.addressTwo else { return }
        if (addressTwo.isEmpty || addressTwo == "") {
            lblAddressTwo.fCityStateZip(city: city, state: state, zip: zip)
            lblCityStateZip.visibility = .gone
        } else {
            lblAddressTwo.text = self.spot.addressTwo
            lblCityStateZip.fCityStateZip(city: city, state: state, zip: zip)
        }
    }
    
    func setupAdd() {
        btnGenericRef.isHidden = false
        btnGenericRef.setTitleColor(UIColor.green, for: .normal)
        btnGenericRef.setTitle("Add to Cart", for: .normal)
    }
    
    func setupRemove() {
        btnGenericRef.isHidden = false
        btnGenericRef.setTitleColor(UIColor.red, for: .normal)
        btnGenericRef.setTitle("Remove", for: .normal)
    }
    
    func setupBlur() {
        //only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibility.isReduceTransparencyEnabled {
            bgBlur.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.bgBlur.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            bgBlur.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            bgBlur.backgroundColor = .clear
        }
    }
}

