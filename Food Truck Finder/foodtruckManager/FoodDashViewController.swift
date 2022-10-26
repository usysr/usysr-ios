//
//  FoodDashViewController.swift
//  Food Truck Finder
//
//  Created by Charles Romeo on 1/9/20.
//  Copyright © 2020 Food Truck Finder Bham. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import RealmSwift

class FoodDashViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var user : User = User()
    var session = Session()
    var fireHelper : FireHelper!
    var ref : DatabaseReference!
    var listOfDashSpots = List<Spot>()
    var foodtruckList = List<Foodtruck>()
    var firstTruck = Foodtruck()
    var loading = UIAlertController()
    
    var MONTH_YEAR_DB = FireHelper.getSpotMonthYearForDBbyDate(date: Date())
    var MONTH_YEAR_DB_NEXT = FireHelper.getSpotMonthYearForDBbyDate(date: Date())

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var profileView: UIView!
    
    @IBOutlet weak var lblAdminName: UILabel!
    @IBOutlet weak var lblAdminEmail: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBAction func btnDoProfile(_ sender: Any) {
        updateProfileAlertController()
    }

    
    func acceptLogout(action:UIAlertAction) {
        Session.doLogout()
        performSegue(withIdentifier: "segueToLoginF", sender: nil)
    }
    

    
    //onCreate
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Starting FoodDashboardController")
        self.loading = Utils().showLoadingAlert()
        
        profileImage.image = UIImage(named: "ProPicTransparent")!
        profileView.backgroundColor = UIColor.fDarkBlue
        Utils().updateStatusBar(view: view)
        
        // TableView Setup
        tableView.rowHeight = 110
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "FoodtruckTableViewCell", bundle: nil), forCellReuseIdentifier: "FoodtruckTableViewCell")
        
        setupDisplay()
    }
    
    func setupDisplay() {
        //SETUP GRABBING SPOTS FOR NEXT MONTH AS WELL
        let date = Date()
        guard let newDate = date.addOneMonth() else { return }
        self.MONTH_YEAR_DB_NEXT = FireHelper.getSpotMonthYearForDBbyDate(date: newDate)
        //General Setup
        if let user = Session.getInstance()?.user, let sess = Session.getInstance() {
            self.user = user
            self.session = sess
            lblAdminName.text = "Welcome, \(user.name)"
            lblAdminEmail.text = user.email
            self.grabSpotsFromFirebaseByUserONE()
            self.foodtruckList = session.foodtrucks
            //reload Locations
            if self.foodtruckList.isEmpty {
                Session.removeAllFoodtrucksFromSession()
                Session.removeRealmFoodtruckObject()
                self.grabFoodtrucksFromFirebase(user: user)
            } else {
                
                if let first = self.foodtruckList.first {
                    self.firstTruck = first
                }
                
                if !self.basicInfoIsNotValid() {
                    let alert = UIAlertController(title: "Required Action", message: "Records do not indicate a truck name, please add one now!", preferredStyle: .alert)
                    let addEventAction = UIAlertAction(title: "Okay", style: .default, handler: { (action) -> Void in
                        //-> Show Profile Alert (which requires a truck name to get out of)
                        self.updateProfileAlertController()
                    })
                    alert.addAction(addEventAction)
                    self.present(alert, animated: true, completion: nil)                }
            }
            
        } else {
            //log!
            dismiss(animated: true, completion: nil)
        }
    }
    
    //TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfDashSpots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.listOfDashSpots[indexPath.row] as Spot
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodtruckTableViewCell") as! FoodtruckTableViewCell
        cell.setupTableCell(spot: row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "spotDetailsAlert") as! SpotDetailsAlertController
        myAlert.spot = self.listOfDashSpots[indexPath.row]
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
    }

    //Grab Locations from Firebase
    func grabSpotsFromFirebaseByUserONE() {
        //Remove all Spots in Dash for new set coming in
        self.listOfDashSpots.removeAll()
        FireHelper.getSpotsForMonth(month: self.MONTH_YEAR_DB).queryOrdered(byChild:"assignedTruckUid")
            .queryEqual(toValue:user.uid).observe(.value, with: { (snapshot) in
            let enumerator = snapshot.children
            self.listOfDashSpots.removeAll()
            while let rest = enumerator.nextObject() as? DataSnapshot {
                //Make obj from snapshot, verify not null
                guard let map = rest.value as? NSObject else { return }
                //Parse Spot
                let newSpot = ParseSpot.parseSpot(map: map)
                //Add Spot to Session
                Session.addSpotToSession(spot: newSpot)
                if (newSpot.status == FireHelper.BOOKED){
                    //If booked, Add To Dash
                    self.listOfDashSpots.append(newSpot)
                }
            }
            //Grab Next Month
            self.grabSpotsFromFirebaseByUserTWO()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //Grab Locations from Firebase
    func grabSpotsFromFirebaseByUserTWO() {
        FireHelper.getSpotsForMonth(month: self.MONTH_YEAR_DB_NEXT).queryOrdered(byChild:"assignedTruckUid")
            .queryEqual(toValue:user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                //Make obj from snapshot, verify not null
                guard let map = rest.value as? NSObject else { return }
                //Parse Spot
                let newSpot = ParseSpot.parseSpot(map: map)
                //Add Spot to Session
                Session.addSpotToSession(spot: newSpot)
                if (newSpot.status == FireHelper.BOOKED){
                    //If booked, Add To Dash
                    self.listOfDashSpots.append(newSpot)
                }
            }
            //Sort List and Reload TableView
            self.doSorting()
            self.tableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    
    //-> Sorting
    func doSorting() {
        self.removeOldSpots()
        self.sortDashSpotsByDate()
    }
    func removeOldSpots() {
        let temp = List<Spot>()
        for s in self.listOfDashSpots {
            //format dates
            if !DateUtils.dateIsOlderThanToday(possibleOldDate: s.date!) {
                temp.append(s)
            }
        }
        self.listOfDashSpots.removeAll()
        self.listOfDashSpots = temp
    }
    func sortDashSpotsByDate() {
        let today = Date()
        let temp = List<Spot>()
        var i = 0
        while temp.count != self.listOfDashSpots.count {
            //check if spot date is equal to today
            let nDay = Calendar.current.date(byAdding: .day, value: i, to: today)!
            let strDay = DateUtils.convertDateToString(dateObject: nDay)
            //add one day to today object, move on
            for s in self.listOfDashSpots {
                //format dates
                if DateUtils.datesDoMatch(dateOne: strDay, dateTwo: s.date!) {
                    temp.append(s)
                }
            }
            i += 1
        }
        self.listOfDashSpots.removeAll()
        self.listOfDashSpots = temp
    }
    //<- Sorting
    
    //Grab Locations from Firebase
    func grabFoodtrucksFromFirebase( user : User ) {
        let temp = Database.database().reference()
        temp.child("Profiles").child("foodtrucks").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                guard let map = rest.value as? NSObject else { return }
                let newTruck = ParseFoodtruck.parseFoodtruck(map: map)
                Session.addFoodTruck(truck: newTruck)
            }
            
            //Verify Basic Info
            if !self.basicInfoIsNotValid() {
                //Show dialog letting user know they have to add this
                let alert = UIAlertController(title: "Required Action", message: "Records do not indicate a truck name, please add one now!", preferredStyle: .alert)
                let addEventAction = UIAlertAction(title: "Okay", style: .default, handler: { (action) -> Void in
                    //-> Show Profile Alert (which requires a truck name to get out of)
                    self.updateProfileAlertController()
                })
                alert.addAction(addEventAction)
                self.present(alert, animated: true, completion: nil)
            }
         }) { (error) in
           print(error.localizedDescription)
       }
    }
    
    
    //Verify Foodtruck info
    func basicInfoIsNotValid() -> Bool {
        
        guard let firstTruck = self.foodtruckList.first else {
            return false
        }
        
        if let truckName = firstTruck.truckName {
            if truckName.isEmpty {
                return false
            }
        }
        if let truckType = firstTruck.truckType {
            if truckType.isEmpty {
                return false
            }
        }
        
        return true
    }
    
    func updateProfileAlertController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "foodProfileController") as! GeneralProfileAlertController
        myAlert.foodtruck = self.firstTruck
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
    }
    
}
