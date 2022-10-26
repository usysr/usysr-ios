//
//  DashboardViewController.swift
//  Food Truck Finder
//
//  Created by Charles Romeo on 1/9/20.
//  Copyright © 2020 FoodTruck Finder. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift

class LocDashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationPicker: UIPickerView!
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    

    var user : User = User()
    var session = Session()
    var ref : DatabaseReference!
    var clearList = true
    var MONTH_YEAR_DB = FireHelper.getSpotMonthYearForDBbyDate(date: Date())
    var MONTH_YEAR_DB_NEXT = FireHelper.getSpotMonthYearForDBbyDate(date: Date())
    var currentLocation = Location()
    var listOfSpots = List<Spot>()
    var locationsList = List<Location>()
    var spotsToQuery = DatabaseReference()
    var locationId = ""
    
    

    @IBAction func btnDoProfile(_ sender: Any) {
        updateProfileAlertController()
    }
    
    
    
    @IBAction func btnDoLogout(_ sender: Any) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "Yes", style: .destructive, handler: acceptLogout)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(acceptAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func acceptLogout(action:UIAlertAction) {
        Session.doLogout()
        performSegue(withIdentifier: "segueToLogin", sender: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
//        setupDisplay() -> This method gets called every single time we see this class/screen.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
        setupDisplay()

        Utils().updateStatusBar(view: view)
    }
    
    func setupDisplay() {
        locationPicker.delegate = self
        locationPicker.dataSource = self
        locationPicker.backgroundColor = UIColor.fDarkBlue
        profileView.backgroundColor = UIColor.fDarkBlue
        
        
        // TableView Setup
        tableView.rowHeight = 110
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "FoodtruckTableViewCell", bundle: nil), forCellReuseIdentifier: "FoodtruckTableViewCell")
        
        //Profile image
        imgProfile.image = UIImage(named: "ProPicTransparent")!
        reloadSession()
        self.locationPicker.reloadAllComponents()
    }
    
    func reloadSession() {
        //SETUP GRABBING SPOTS FOR NEXT MONTH AS WELL
        let date = Date()
        guard let newDate = date.addOneMonth() else { return }
        self.MONTH_YEAR_DB_NEXT = FireHelper.getSpotMonthYearForDBbyDate(date: newDate)
        //General Setup
        if let sess = Session.getInstance(), let user = Session.getInstance()?.user {
            lblName.text = "Welcome, \(user.name)"
            lblEmail.text = user.email
            self.locationsList = sess.locations
            //reload Locations
            if self.locationsList.isEmpty {
                Session.removeAllLocationsFromSession()
                Session.removeRealmLocationObject()
                self.grabLocationsFromFirebase(user: user)
            } else {
                guard let _ = self.locationsList[0]["locationName"] as? String else {
                    self.grabLocationsFromFirebase(user: user)
                    return
                }
                self.currentLocation = self.locationsList[0]
                if let id = self.locationsList[0]["id"] as? String {
                    self.locationId = id
                }
                self.grabSpotsFromFirebaseByLocationONE(locationId: self.currentLocation.id)
            }
            
        } else {
            print("LocDashboardVC: No Session or User found!")
        }
    }
    
//----------------------------------------------------------------------------------------------------------------------------\\
    
    // -> LOCATION PICKER <- \\
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return locationsList.count
    }
    
    // Set Title from Location List
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return locationsList[row]["locationName"] as? String
    }

    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //Grab the location name from the picker
        if self.locationsList.isEmpty {
            self.reloadSession()
        } else {
            if let locId = locationsList[row]["id"] as? String {
                //Reload Events based only on this location
                self.locationId = locId
                self.grabSpotsFromFirebaseByLocationONE(locationId: locId)
            }
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        guard let str = locationsList[row]["locationName"] as? String else { return nil }
        let attributedString = NSAttributedString(string: str, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        return attributedString
    }
//----------------------------------------------------------------------------------------------------------------------------\\
    
    //TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfSpots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.listOfSpots[indexPath.row] as Spot
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodtruckTableViewCell") as! FoodtruckTableViewCell
        cell.setupTableCell(spot: row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "spotDetailsAlert") as! SpotDetailsAlertController
        myAlert.spot = self.listOfSpots[indexPath.row]
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
    }
    
    //Grab Locations from Firebase
    func grabSpotsFromFirebaseByLocationONE(locationId : String) {
        self.listOfSpots.removeAll()
        self.spotsToQuery = FireHelper.getSpotsForMonth(month: self.MONTH_YEAR_DB)
        self.spotsToQuery.queryOrdered(byChild:"locationUUID")
            .queryEqual(toValue:locationId).observe(.value, with: { (snapshot) in
            let enumerator = snapshot.children
            self.listOfSpots.removeAll()
            self.clearList = false
            while let rest = enumerator.nextObject() as? DataSnapshot {
                guard let map = rest.value as? NSObject else { return }
                let newSpot = ParseSpot.parseSpot(map: map)
                if newSpot.locationUUID == "" { continue }
                if self.isOldSpot(date: newSpot.date!) { continue }
                if self.spotIsInListOfSpots(id: newSpot.id ?? "") { continue }
                self.listOfSpots.append(newSpot)
                print("Added Spot: \(newSpot)")
            }
            self.grabSpotsFromFirebaseByLocationTWO(locationId: self.locationId)
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //Grab Locations from Firebase
    func grabSpotsFromFirebaseByLocationTWO(locationId : String) {
        
        self.spotsToQuery = FireHelper.getSpotsForMonth(month: self.MONTH_YEAR_DB_NEXT)
        self.spotsToQuery.queryOrdered(byChild:"locationUUID")
            .queryEqual(toValue:locationId).observeSingleEvent(of: .value, with: { (snapshot) in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                guard let map = rest.value as? NSObject else { return }
                let newSpot = ParseSpot.parseSpot(map: map)
                if newSpot.locationUUID == "" { continue }
                if self.isOldSpot(date: newSpot.date!) { continue }
                if self.spotIsInListOfSpots(id: newSpot.id ?? "") { continue }
                self.listOfSpots.append(newSpot)
                print("Added Spot: \(newSpot)")
            }
            self.doSorting()
                  
            DispatchQueue.main.async {
               self.tableView.reloadData()
           }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func spotIsInListOfSpots(id: String) -> Bool {
        if self.listOfSpots.isEmpty || id == "" { return false }
        for s in self.listOfSpots {
            guard let i = s.id else { return true }
            if i == id { return true }
        }
        return false
    }

  
    //Grab Locations from Firebase
    func grabLocationsFromFirebase( user : User ){
        if !self.locationsList.isEmpty { self.locationsList.removeAll() }
        self.ref = Database.database().reference()
        self.ref.child("Profiles").child("locations").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                guard let map = rest.value as? NSObject else { return }
                let newLocation = ParseLocation.parseLocation(map: map)
                if self.locationId == "" { self.locationId = newLocation.id }
                Session.addUpdateLocation(location: newLocation)
            }
            DispatchQueue.main.async {
                self.grabSpotsFromFirebaseByLocationONE(locationId: self.locationId)
                self.ref.removeAllObservers()
                self.locationPicker.reloadAllComponents()
            }
         }) { (error) in
           print(error.localizedDescription)
       }
    }
    
//    func locationDoesExist(newLocation:Location) -> Bool {
//        if let sess = Session.getInstance() {
//            //Stay safe, stay here.
//            self.session = sess
//            self.locationsList = sess.locations
//            let locList = sess.locations
//            for item in locList {
//                if item.id == newLocation.id {
//                    return false
//                }
//            }
//        }
//        return true
//    }
    
    //Display User Profile Controller
    func updateProfileAlertController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "foodProfileController") as! GeneralProfileAlertController
        //add flag for 
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
    }
    
    //-> Sorting
    func doSorting() {
        self.sortDashSpotsByDate()
    }
    func isOldSpot(date:String) -> Bool {
        //format dates
        if DateUtils.dateIsOlderThanToday(possibleOldDate: date) {
            return true
        }
        return false
    }
    func sortDashSpotsByDate() {
        let today = Date()
        let temp = List<Spot>()
        var i = 0
        while temp.count != self.listOfSpots.count {
            //check if spot date is equal to today
            let nDay = Calendar.current.date(byAdding: .day, value: i, to: today)!
            let strDay = DateUtils.convertDateToString(dateObject: nDay)
            //add one day to today object, move on
            for s in self.listOfSpots {
                //format dates
                if DateUtils.datesDoMatch(dateOne: strDay, dateTwo: s.date!) {
                    temp.append(s)
                }
            }
            i += 1
        }
        self.listOfSpots.removeAll()
        self.listOfSpots = temp
    }
    //<- Sorting

}
