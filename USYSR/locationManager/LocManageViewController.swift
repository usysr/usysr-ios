//
//  ManageViewController.swift
//  Food Truck Finder
//
//  Created by Charles Romeo on 1/9/20.
//  Copyright © 2020 Food Truck Finder Bham. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import RealmSwift

class LocManageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var _MODE : Int = 0
    var _DISPLAY = 0
    var _NEW = 1
    var _EDIT = 2
    
    var isUpdate = false
    var isCancel = false
    var isClear = false
    
    var user : User = User()
    var session : Session = Session()
    var fireHelper : FireHelper!
    var ref : DatabaseReference!
    var listOfLocations = List<Location>()
    var updatedLocationObject = Location()
    var originalLocationObject = Location()
    var masterIndexRow : IndexPath!
    
    //TODO: Turn into Alert Popup
    @IBOutlet var bgView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var editLocName: UITextField!
    @IBOutlet weak var editLocAddressOne: UITextField!
    @IBOutlet weak var editLocAddressTwo: UITextField!
    @IBOutlet weak var editLocCity: UITextField!
    @IBOutlet weak var editLocState: UITextField!
    @IBOutlet weak var editLocZip: UITextField!
    @IBOutlet weak var editLocEstPeople: UITextField!
    @IBOutlet weak var editLocParkingInfo: UITextView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var locName:String?
    
    //Add New Location Button
    @IBOutlet weak var btnAddRef: UIButton!
    @IBAction func btnAddLocation(_ sender: UIButton) {
        
        //TODO: UPDATE OR ADD?
        if _MODE == _EDIT {
            
            if (verifyUpdatedLocationObject()){
                if getFieldsForUpdatedLocation() {
                    self.updateLocationInFirebase()
                }
                
            } else {
                //show dialog
                let alert = UIAlertController(title: "Required Field Empty or No Changes Detected", message: "Please Verify Location Details.", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Okay", style: .destructive, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
            
        } else {
            //Check if fields are empty?
            if (locationObjectIsEmpty()){
                let nLocation = setNewLocation()
//                nLocation.save()
                self.addLocationToFirebase(location: nLocation)
            } else {
                //show dialog
                let alert = UIAlertController(title: "Required Field Empty", message: "One or more field(s) is empty", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Okay", style: .destructive, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    /**
    * -> Clear
     * ->
     */
    @IBOutlet weak var btnGeneralRef: UIButton!
    @IBAction func btnGeneral(_ sender: Any) {
        
        if isCancel {
            clearAllFields()
            setDisplayMode()
        } else if isClear {
            clearAllFields()
        }
        
    }
    
    func reloadSession() {
        clearAllFields()
        //Checking User, Setting User
         if let sess = Session.getInstance() {
            //Stay safe, stay here.
            self.session = sess
            self.listOfLocations = sess.locations
            self.tableView.reloadData()
            print("No error!!")
        }else{
            dismiss(animated: true)
        }
    }
    
    //onCreate
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        Utils().updateStatusBar(view: view)
        //Checking User, Setting User
        if let sess = Session.getInstance() {
            //Stay safe, stay here.
            self.session = sess
            self.listOfLocations = sess.locations
            
            if let u = sess.user {
                self.user = u
                if (self.listOfLocations.isEmpty){
                    grabLocationsFromFirebase(user: u)
                }
            }
            print("No error!!")
       }else{
            dismiss(animated: true)
       }
        
        headerView.backgroundColor = UIColor.fDarkBlue
        btnAddRef.fDesignImageLeftTitleRight(title: "Location", image: UIImage.f_add_Light)
        btnGeneralRef.fDesignImageLeftTitleRight(title: "General", image: UIImage.f_minus_Light)
        btnGeneralRef.isHidden = true

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.rowHeight = 115
        tableView.register(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: "LocationTableViewCell")
    }
    
    func setDisplayMode() {
        self._MODE = self._DISPLAY
        //clear all fields
        self.btnGeneralRef.isHidden = true
        self.btnAddRef.setTitle("Location", for: .normal)
        self.isUpdate = false
        self.isCancel = false
        self.isClear = false
    }

    func setNewMode() {
        self._MODE = self._NEW
        self.btnAddRef.setTitle("Location", for: .normal)
//        self.btnGeneralRef.setTitle("Clear", for: .normal)
        self.isClear = true
        self.isUpdate = false
        self.isCancel = false
    }
    
    func setEditMode() {
        self._MODE = self._EDIT
        self.btnAddRef.setTitle("Update", for: .normal)
        self.btnGeneralRef.setTitle("Cancel", for: .normal)
        self.btnGeneralRef.isHidden = false
        self.btnAddRef.isEnabled = true
        self.isUpdate = true
        self.isCancel = true
    }

    //TABLE VIEW / LIST VIEW FOR LOCATIONS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfLocations.count
    }
    
    //TABLE VIEW / Setup View
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell") as! LocationTableViewCell
        cell.user = self.user
        cell.location = self.listOfLocations[indexPath.row]
        cell.controller = self
        cell.setupCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Alert to delete?
//        self.masterIndexRow = indexPath
//        let loc = self.listOfLocations[indexPath.row] as Location
//        //Set the id for firebase
//        self.originalLocationObject = loc
//
//        //put the contents of the location inside the text fields for edit
//        self.editLocName.text = loc.locationName
//        self.editLocAddressOne.text = loc.addressOne
//        self.editLocAddressTwo.text = loc.addressTwo
//        self.editLocCity.text = loc.city
//        self.editLocState.text = loc.state
//        self.editLocZip.text = loc.zip
//        self.editLocEstPeople.text = loc.estPeople
//
//        //setup buttons now
//        self.setEditMode()
    }
    
    //Grab text from fields and set them to new location object
    func clearAllFields() {
        
        self.editLocName.text = ""
        self.editLocAddressOne.text = ""
        self.editLocAddressTwo.text = ""
        self.editLocCity.text = ""
        self.editLocState.text = ""
        self.editLocZip.text = ""
        self.editLocEstPeople.text = ""
        self.editLocParkingInfo.text = ""
        
    }
        
    //Grab text from fields and set them to new location object
    func setNewLocation() -> Location {
        let newLocation : Location = Location()
        newLocation.id = UUID().uuidString
        newLocation.locationName = editLocName.text
        newLocation.addressOne = editLocAddressOne.text
        newLocation.addressTwo = editLocAddressTwo.text
        newLocation.city = editLocCity.text
        newLocation.state = editLocState.text
        newLocation.zip = editLocZip.text
        newLocation.estPeople = editLocEstPeople.text
        newLocation.details = editLocParkingInfo.text
        return newLocation
    }
    
    //Grab text from fields and set them to new location object
    func getFieldsForUpdatedLocation() -> Bool {
        self.updatedLocationObject.id = originalLocationObject.id
        self.updatedLocationObject.locationName = editLocName.text
        self.updatedLocationObject.addressOne = editLocAddressOne.text
        self.updatedLocationObject.addressTwo = editLocAddressTwo.text
        self.updatedLocationObject.city = editLocCity.text
        self.updatedLocationObject.state = editLocState.text
        self.updatedLocationObject.zip = editLocZip.text
        self.updatedLocationObject.estPeople = editLocEstPeople.text
        self.updatedLocationObject.details = editLocParkingInfo.text
        return true
    }
    
    //Make sure required fields are not empty
    func locationObjectIsEmpty() -> Bool {
        if (self.editLocName.text == "" || self.editLocName.text == nil) {
            return false
        } else if (self.editLocAddressOne.text == "" || self.editLocAddressOne.text == nil) {
            return false
        } else if (self.editLocCity.text == "" || self.editLocCity.text == nil) {
            return false
        } else if (self.editLocState.text == "" || self.editLocState.text == nil) {
            return false
        } else if (self.editLocZip.text == "" || self.editLocZip.text == nil) {
            return false
        } else if (self.editLocEstPeople.text == "" || self.editLocEstPeople.text == nil) {
            return false
        } else if (self.editLocParkingInfo.text == "" || self.editLocParkingInfo.text == nil) {
            return false
        } else {
            return true
        }
    }
    
    //Make sure required fields are not empty
    func verifyUpdatedLocationObject() -> Bool {
        if (self.editLocName.text == "" || self.editLocName.text == nil) {
            return false
        } else if (self.editLocAddressOne.text == "" || self.editLocAddressOne.text == nil) {
            return false
        } else if (self.editLocCity.text == "" || self.editLocCity.text == nil) {
            return false
        } else if (self.editLocState.text == "" || self.editLocState.text == nil) {
            return false
        } else if (self.editLocZip.text == "" || self.editLocZip.text == nil) {
            return false
        } else if (self.editLocEstPeople.text == "" || self.editLocEstPeople.text == nil) {
            return false
        } else if (self.editLocParkingInfo.text == "" || self.editLocParkingInfo.text == nil) {
            return false
        }
        
        if (self.editLocName.text == self.originalLocationObject.locationName
            && self.editLocAddressOne.text == self.originalLocationObject.addressOne
            && self.editLocAddressTwo.text == self.originalLocationObject.addressTwo
            && self.editLocCity.text == self.originalLocationObject.city
            && self.editLocState.text == self.originalLocationObject.state
            && self.editLocZip.text == self.originalLocationObject.zip
            && self.editLocEstPeople.text == self.originalLocationObject.estPeople
            && self.editLocParkingInfo.text == self.originalLocationObject.details) {
            return false
        }
        
        return true
    }
    
    //Add location to Firebase for User
    func addLocationToFirebase(location : Location){
        //Save Profile
        ref = FireHelper.getLocationForUser(key: user.uid).child(String(location.id))
        ref.setValue(location.convertToDictionary()) { (error:Error?, ref:DatabaseReference) in
            //Error Handling
            if let error = error {
                //Failed
                print(error)
            } else {
                //Successfully saved
                print("Success!")
                DispatchQueue.main.async {
                    Session.addUpdateLocation(location: location)
                    self.reloadSession()
                    self.view.endEditing(true)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    //Add location to Firebase for User
    func updateLocationInFirebase(){
       //Save Profile
       ref = FireHelper.getLocationForUser(key: user.uid).child(String(updatedLocationObject.id))
       ref.updateChildValues(updatedLocationObject.convertToDictionary()) { (error:Error?, ref:DatabaseReference) in
           //Error Handling
           if let error = error {
               //Failed
               print(error)
           } else {
                //Successfully saved
                print("Success!")
                DispatchQueue.main.async {
                    Session.addUpdateLocation(location: self.updatedLocationObject)
                    self.reloadSession()
                }
           }
       }
    }
    
    //Remove location to Firebase for User
    func removeLocationFromFirebase( location : Location ){
        //Save Profile
        ref = FireHelper.getLocationForUser(key: user.uid).child(location.id)
        ref.removeValue { error, _ in
            print(error as Any)
        }
       
    }
    
    //TODO:
    //Grab Locations from Firebase
    func grabLocationsFromFirebase( user : User ){
        let temp = Database.database().reference()
        temp.child("Profiles").child("locations").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                guard let map = rest.value as? NSObject else { return}
                let newLocation = ParseLocation.parseLocation(map: map)
                Session.addUpdateLocation(location: newLocation)
            }
            DispatchQueue.main.async {
                self.reloadSession()
            }
         }) { (error) in
           print(error.localizedDescription)
       }

    }
    

}

