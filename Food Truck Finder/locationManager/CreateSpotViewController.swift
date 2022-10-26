//
//  LocationAlertViewController.swift
//  Food Truck Finder
//
//  Created by Charles Romeo on 3/1/20.
//  Copyright © 2020 Food Truck Finder Bham. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import FirebaseDatabase

class CreateSpotViewController: UIViewController {

    var calDelegate : LocCalendarViewController = LocCalendarViewController()
    var fireHelper : FireHelper!
    var ref : DatabaseReference!
    var user = User()
    var loading = UIAlertController()
    var locationsList = List<Location>()
    var finalLocation = Location()
    var queuedListOfSpots = List<Spot>()
    var currentDate = Date()
    var currentDateString = ""
    var listOfSpots = List<Spot>()
    var selectedDatesList = List<String>()
    var isDoubleBook = false
    var isEntree = true
    var isDessert = false
    
    var txtLocationName = ""
    var txtLunchDinner = "Lunch"
    var txtEntreeDessert = ""
    
    @IBOutlet weak var progressSpinner: UIActivityIndicatorView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblEntreeSwitch: UILabel!
    @IBOutlet weak var entreeSwitchRef: UISwitch!
    @IBAction func entreeSwitch(_ sender: Any) {
        //TODO:
        if isEntree {
            entreeSwitchRef.isOn = false
            isEntree = false
        } else {
            entreeSwitchRef.isOn = true
            isEntree = true
        }
        checkDoubleBooking()
    }
    @IBOutlet weak var lblDessertSwitch: UILabel!
    @IBOutlet weak var dessertSwitchRef: UISwitch!
    @IBAction func dessertSwitch(_ sender: Any) {
        //TODO:
        if isDessert {
            dessertSwitchRef.isOn = false
            isDessert = false
        } else {
            dessertSwitchRef.isOn = true
            isDessert = true
        }
        checkDoubleBooking()
    }
    
    @IBOutlet weak var lblDoubleSpotWarning: UILabel!
    @IBOutlet weak var alertDialogView: UIView!
    @IBOutlet weak var estPeople: UITextField!
    @IBOutlet weak var ctrlLunchDinner: UISegmentedControl!
    @IBAction func ctrlHasChangedLD(_ sender: Any) {
        switch ctrlLunchDinner.selectedSegmentIndex
        {
        case 0:
            txtLunchDinner = "Lunch"
        case 1:
            txtLunchDinner = "Dinner"
        default:
            break
        }
    }
    
    func getFoodType() -> String {
        
        if entreeSwitchRef.isOn && !dessertSwitchRef.isOn {
            return Spot.ENTREE
        }
        
        if !entreeSwitchRef.isOn && dessertSwitchRef.isOn {
            return Spot.DESSERT
        }
        
        return Spot.ENTREE
    }
    
    func checkFields() -> Bool {
        if self.estPeople.text == "" {
            return false
        }
        if self.isEntree == false && self.isDessert == false {
            return false
        }
        
        guard let addressOne = self.finalLocation.addressOne else { return false }
        if addressOne.isEmpty { return false }
        guard let zip = self.finalLocation.zip else { return false }
        if zip.isEmpty { return false }
        guard let state = self.finalLocation.state else { return false }
        if state.isEmpty { return false }
        guard let city = self.finalLocation.city else { return false }
        if city.isEmpty { return false }
    
        return true
    }
    
    func loopSpotsForSameDate(newDate:String, newFoodType:String, newMealTime:String) -> Bool {
        //TODO: VERIFY -> THEY CANT MAKE MORE THAN ONE SPOT FOR THE SAME DAY AND TIME.
        //CHECK IF THIS DATE AND TIME EXISTS AS A SPOT
        //4 spots per day (2 entree/2 dessert) (2 spots for lunch, 2 for dinner)
        if self.listOfSpots.isEmpty { return true }
        //Loop through all Spots (s) in ListOfSpots
        for oldSpot in self.listOfSpots {
            /** SAFE SET VARIABLES **/
            //safe set date (oldSpot)
            guard let oldSpotsDate = oldSpot.date else {
                let alert = doAlert(title: "Error", message: "Something seems to be wrong, please try again later.")
                self.present(alert, animated: true, completion: nil)
                return false //Null Safe
            }
            //safe set foodType (oldSpot)
            guard let oldSpotsFoodType = oldSpot.foodType else {
                let alert = doAlert(title: "Error", message: "Something seems to be wrong, please try again later.")
                self.present(alert, animated: true, completion: nil)
                return false //Null Safe
            }
            //safe set mealTime
            guard let oldSpotsMealTime = oldSpot.mealTime else {
                let alert = doAlert(title: "Error", message: "Something seems to be wrong, please try again later.")
                self.present(alert, animated: true, completion: nil)
                return false //Null Safe
            }
            /** VERIFICATION **/
            //if NEW SPOT's Date == ListOfSpot's Date -> (date)
            let time = Spot().parseTime(str: newMealTime)
            if oldSpotsDate == newDate && oldSpotsMealTime == time {
                //if oldFoodType == BOTH -> (entree/dessert)
                    //-> if it is both, then this is impossible since the dates match, so one of the two can't work
                if newFoodType == "both" {
                    //TODO: USER IS TRYING TO MAKE 2 SPOTS-> CAN'T DO BOTH AS ONE OF THE TWO SPOTS CONFLICT
                    let alert = doAlert(title: "Date Conflict", message: "Please verify no other spots are created at this date and time.")
                    self.present(alert, animated: true, completion: nil)
                    return false
                //if foodtype == foodtype -> (entree/dessert)
                    //-> if not both, make sure the one new spot doesn't match the one old spot
                } else {
                    if oldSpotsFoodType == newFoodType {
                        //TODO: USER IS TRYING TO MAKE 1 SPOT -> CAN'T DO THIS BECAUSE IT CONFLICTS
                        let alert = doAlert(title: "Date Conflict", message: "Please verify no other spots are created at this date and time.")
                        self.present(alert, animated: true, completion: nil)
                        return false
                    }
                }
            }
        }
        return true
    }
    
    @IBAction func btnAdd(_ sender: Any) {
        if checkFields() {
            var i = 0
            for _ in selectedDatesList {
                if isDoubleBook {
                    //verify dates do not match
                    if !loopSpotsForSameDate(newDate: self.selectedDatesList[i], newFoodType: "both", newMealTime: txtLunchDinner) { return }
                    //do twice
                    self.queuedListOfSpots.append(createSpot(dateInt: i, foodType: Spot.ENTREE))
                    self.queuedListOfSpots.append(createSpot(dateInt: i, foodType: Spot.DESSERT))
                } else {
                    //verify dates do not match
                    if !loopSpotsForSameDate(newDate: self.selectedDatesList[i], newFoodType: getFoodType(), newMealTime: txtLunchDinner) { return }
                    self.queuedListOfSpots.append(createSpot(dateInt: i, foodType: getFoodType()))
                }
                //send spot to firebase
                queueForCreatingSpots()
                //Increment and Move on
                i = i + 1
            }
        } else {
            //show dialog
            let alert = doAlert(title: "Required Field Empty", message: "Please check fields and try again.")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func doAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Okay", style: .destructive, handler: nil)
        alert.addAction(cancelAction)
        return alert
    }
    
    func createSpot(dateInt : Int, foodType: String) -> Spot {
        let spot = Spot()
        spot.id = UUID().uuidString
        spot.date = self.selectedDatesList[dateInt]
        spot.spotManager = user.name
        spot.locationName = finalLocation.locationName
        spot.locationUUID = finalLocation.id
        spot.addressOne = finalLocation.addressOne
        spot.addressTwo = finalLocation.addressTwo
        spot.city = finalLocation.city
        spot.state = finalLocation.state
        spot.zip = finalLocation.zip
        spot.parkingInfo = finalLocation.details
        spot.foodType = foodType
        spot.mealTime = txtLunchDinner
        spot.estPeople = estPeople.text
        spot.status = Spot.AVAILABLE
        spot.price = Spot.PRICE //How does he want to handle setting the price
        return spot
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.progressSpinner.visibility = .gone
        self.progressSpinner.isHidden = true
        if let session = Session.getInstance(), let u = session.user {
            //Stay safe, stay here.
            self.user = u
            self.locationsList = session.locations
            print("No error!!")
        }else{
             dismiss(animated: true)
        }
        
        setupDisplay()
    }
    
    func setupDisplay() {
        self.hideKeyboardWhenTappedAround()
        self.alertDialogView.fSpotDetailsPopUpDesign()
        dessertSwitchRef.isOn = false
        entreeSwitchRef.isOn = true
        lblDoubleSpotWarning.isHidden = true
        
        lblHeader.setTitleAndImage(text: "New Spot", leftIcon:  UIImage(named:"f_spot_one_dark.png")?.resizeImage(scale: 0.25), rightIcon: nil)
        lblEntreeSwitch.setTitleAndImage(text: Spot.ENTREE, leftIcon:  UIImage(named:"f_food_dark.png")?.resizeImage(scale: 0.25), rightIcon: nil)
        lblDessertSwitch.setTitleAndImage(text: Spot.DESSERT, leftIcon:  UIImage(named:"f_food_dark.png")?.resizeImage(scale: 0.25), rightIcon: nil)
    }
    
    func checkDoubleBooking() {
        if isEntree && isDessert {
            self.isDoubleBook = true
            lblDoubleSpotWarning.isHidden = false
            return
        }
        self.isDoubleBook = false
        lblDoubleSpotWarning.isHidden = true
        return
    }
    
    func startProgress() {
        self.progressSpinner.visibility = .visible
        self.progressSpinner.isHidden = false
        self.progressSpinner.startAnimating();
    }
    
    func stopProgress() {
        self.progressSpinner.stopAnimating();
    }
    
    func queueForCreatingSpots() {
        //start
        self.startProgress()
        if self.queuedListOfSpots.isEmpty {
            //end
            self.stopProgress()
            self.dismiss(animated: true, completion: nil)
        }
        guard let spot = queuedListOfSpots.first else { return }
        guard let date = spot.date else { return }
        guard let d = DateUtils.convertToDate(dateUTC: date) else { return }
        let m = FireHelper.getSpotMonthYearForDBbyDate(date: d)
        self.addSpotToFirebase(spot: spot, month: m)
        self.queuedListOfSpots.removeFirst()
    }
    
    //Add spot to Firebase for User
    func addSpotToFirebase(spot : Spot, month : String){
        //Save Profile
        if let i = spot.id {
            self.ref = FireHelper.getSpotsForMonth(month: month).child(String(i))
            self.ref.setValue(spot.convertToDictionary()) { (error:Error?, ref:DatabaseReference) in
                //Error Handling
                if let error = error {
                    //Failed -> Let user know
                    print(error)
                } else {
                    //Successfully saved
                    self.queueForCreatingSpots()
                    print("Success!")
                }
            }
        }
        
    }
    

}
