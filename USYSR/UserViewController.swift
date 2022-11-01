//
//  userViewController.swift
//  Food Truck Finder
//
//  Created by Michael Cather on 12/26/20.
//  Copyright © 2020 Adrenaline Life. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import FirebaseDatabase
import RealmSwift


class UserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate { 
    
    
    var user : User = User()
    var fireHelper : FireHelper!
    var ref : DatabaseReference!
    var listOfDashSpots = List<Spot>()
    var loading = UIAlertController()
    
     var MONTH_YEAR_DB = FireHelper.getSpotMonthYearForDBbyDate(date: Date())
     var MONTH_YEAR_DB_NEXT = FireHelper.getSpotMonthYearForDBbyDate(date: Date())
    
    let providers: [FUIAuthProvider] = [
      FUIGoogleAuth(),
    ]
    
    @IBOutlet weak var btnCreateAcct: UIButton!
    @IBOutlet weak var UserBasicView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils().updateStatusBar(view: view)
        buttonDesignSetup()
        UserBasicView.backgroundColor = UIColor.fDarkBlue
        navigationController?.navigationBar.tintColor = UIColor.fDarkBlue
        
        
    }
    
    func buttonDesignSetup() {
           btnCreateAcct.fDesignImageLeftTitleRight(title: "Are you a Food Truck?", image: UIImage.f_dashboard_Dark)
         
       }
    
    
    @IBAction func btnCreateAcct(_ sender: UIButton) {
        
       // Create default Auth UI
        let authUI = FUIAuth.defaultAuthUI()
        // Check that it isn't nil
        guard authUI != nil else { return }
        // Set delegate and specify sign in options
        authUI?.delegate = self as FUIAuthDelegate
        authUI?.providers = [FUIEmailAuth()]
        // Get the auth view controller and present it
        let authViewController = authUI!.authViewController()
        print("Starting Firebase PreMade SignInController")
        present(authViewController, animated: true, completion: nil)
        
    }
    
    //Save Profile
    func saveProfileToFirebase( user : User ){
        print("Saving Profile -> AuthController")
        ref = FireHelper.getUsers().child(user.uid)
        ref.updateChildValues(user.convertToDictionary()) { (error:Error?, ref:DatabaseReference) in
            //Error Handling
            if let error = error {
                //TODO: NEED TO SHOW ERROR FOR THE USER AND HANDLE THIS PROPERLY!!
                print(error)
            } else {
                //Successfully saved
                print("User saved to Firebase")
                self.navigateUser(user: user)
            }
        }
        
    }
    
    func grabProfile( user : User ){
            print("Grabbing Profile -> AuthController")
            ref = FireHelper.getUsers().child(user.uid)
            ref.observe(.value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? NSDictionary {
                //If we have a profile, set the auth
                if let _ = value["auth"] as? String {
                    //if user is Waiting, bail
    //                if authValue == FireHelper.WAITING { return }
                    //create new updated user
                    let updatedUser = ParseUser.parseUser(value: value)
                    //save updated user details
                    Session.updateUser(updatedUser: updatedUser)
                    self.navigateUser(user: updatedUser)
                } else {
                    //else?
                    user.auth = FireHelper.WAITING
                    print("Auth -> Failed to grab auth value")
                    self.performSegue(withIdentifier: "ToUserDash", sender: nil)
                }
            } else {
                //No user in database, save one and set them to auth = "waiting"
                self.saveProfileToFirebase(user: user)
            }
             
            }) { (error) in
                print(error.localizedDescription)
            }
        
        }
    
    func navigateUser(user : User){
        //-> FoodTruck Dashboard
        if user.auth == FireHelper.FOODTRUCK_MANAGER {
            print("Segue to Foodtruck -> AuthController")
            guard let selfRef = self.ref else {
                performSegue(withIdentifier: "userFoodTruck", sender: nil)
                return
            }
            selfRef.removeAllObservers()
            performSegue(withIdentifier: "userFoodTruck", sender: nil)
        }

        //-> Location Manager Dashboard
        if user.auth == FireHelper.LOCATION_MANAGER {
            print("Segue to Location -> AuthController")
            guard let selfRef = self.ref else {
                performSegue(withIdentifier: "userLocation", sender: nil)
                return
            }
            selfRef.removeAllObservers()
            performSegue(withIdentifier: "userLocation", sender: nil)
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
        FireHelper.getSpotsForMonth(month: self.MONTH_YEAR_DB)
            .observe(.value, with: { (snapshot) in
            let enumerator = snapshot.children
            self.listOfDashSpots.removeAll()
            while let rest = enumerator.nextObject() as? DataSnapshot {
                //Make obj from snapshot, verify not null
                guard let map = rest.value as? NSObject else { return }
                //Parse Spot
                let newSpot = ParseSpot.parseSpot(map: map)
                //Add Spot to Session
                if (newSpot.status == FireHelper.BOOKED){
                    //If booked, Add To Dash
                    self.listOfDashSpots.append(newSpot)
                }
            }
            //Grab Next Month
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

}

extension UserViewController: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        // Check for error
        guard error == nil else { return }
        let newUser = User()
        newUser.name = (authDataResult?.user.displayName)!
        newUser.email = (authDataResult?.user.email)!
        newUser.uid = (authDataResult?.user.uid)!
        newUser.auth = FireHelper.WAITING
        //build session here
        Session.createSession(user: newUser)
        print("Auth-> Session Created & User Saved")
        //get auth from firebase
        self.grabProfile(user: newUser)
        self.navigateUser(user: User())
     //   self.grabProfile(user: newUser)
    }
    
}
