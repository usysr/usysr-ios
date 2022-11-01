//
//  FoodProfileAlertController.swift
//  Food Truck Finder
//
//  Created by Charles Romeo on 5/16/20.
//  Copyright © 2020 Adrenaline Life. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

class GeneralProfileAlertController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var ref : DatabaseReference!
    var user : User?
    var session : Session?
    var foodtruck : Foodtruck = Foodtruck()
    var loading = UIAlertController()
    var isLocationUser = false
    var isNewTruck = false
    var txtEntreeDessert = "Entree"
    var foodTypeData: [String] = [String]()
    var subFoodTypeData: [String] = [String]()
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var innerView: UIView!
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var editName: UITextField!
    @IBOutlet weak var editEmail: UITextField!
    @IBOutlet weak var editPhone: UITextField!
    @IBOutlet weak var lblTruckType: UILabel!
    @IBOutlet weak var lblSubTruckType: UILabel!
    @IBOutlet weak var editTruckName: UITextField!
    @IBOutlet weak var foodTypePicker: UIPickerView!
    @IBOutlet weak var subFoodTypePicker: UIPickerView!
    @IBOutlet weak var btnLogoutRef: UIButton!
    
    //TRUCK TYPE SWITCH
    
    @IBAction func btnSave(_ sender: Any) {
        if isLocationUser {
            grabLocationFieldsForUpdate()
        } else {
            grabFoodTruckFieldsForUpdate()
        }
        
    }
    @IBAction func btnClose(_ sender: Any) {
        if isLocationUser {
            if checkLocationCloseRequiredFields() {
                dismiss(animated: true, completion: nil)
            }
        } else {
            if checkFoodTruckCloseRequiredFields() {
                dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    @IBOutlet weak var ctrlEntreeDessert: UISegmentedControl!
    @IBAction func ctrlHasChangedLD(_ sender: Any) {
        switch ctrlEntreeDessert.selectedSegmentIndex
        {
        case 0:
            self.txtEntreeDessert = "Entree"
        case 1:
            self.txtEntreeDessert = "Dessert"
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils().updateStatusBar(view: view)
        self.hideKeyboardWhenTappedAround()
        self.loading = Utils().showLoadingAlert()
//        bgView.fSpotDetailsPopUpDesign()
        
        // Connect data:
        self.foodTypePicker.delegate = self
        self.foodTypePicker.dataSource = self
        
        self.subFoodTypePicker.delegate = self
        self.subFoodTypePicker.dataSource = self
        
         foodTypeData = ["Mexican", "Italian", "Indian", "Cajun", "Soul", "Asian", "Mediterranean", "American", "Caribbean", "Sandwiches", "Pizza", "Vegan", "Acai Bowl", "Vegetarian"]
        
         subFoodTypeData = ["Mexican", "Italian", "Indian", "Cajun", "Soul", "Asian", "Mediterranean", "American", "Caribbean", "Sandwiches", "Pizza", "Vegan", "Acai Bowl", "Vegetarian", "None"]
        

        // Do any additional setup after loading the view.
        if let user = Session.getInstance()?.user, let sess = Session.getInstance() {
            self.user = user
            self.session = sess
            
            if let f = sess.foodtrucks.first {
                self.foodtruck = f
            }
            
            if user.auth == FireHelper.LOCATION_MANAGER {
                self.isLocationUser = true
                setupLocationAuth()
            } else {
                setupFoodTruckAuth()
            }
        } else {
            //TODO:
            dismiss(animated: true, completion: nil)
        }
    }
    
    func reloadSession() {
        // Do any additional setup after loading the view.
        if let user = Session.getInstance()?.user, let sess = Session.getInstance() {
            self.user = user
            self.session = sess
            if let f = sess.foodtrucks.first {
                self.foodtruck = f
            }
        } else {
            //TODO:
            dismiss(animated: true, completion: nil)
        }
    }
    
    func setupFoodTruckAuth() {
        editName.text = user?.name
        editEmail.text = user?.email
        editPhone.text = user?.phone
        editTruckName.text = self.foodtruck.truckName
        
        if let type = self.foodtruck.truckType {
            self.txtEntreeDessert = type
        }
        
        if self.txtEntreeDessert.isEmpty {
            return
        }
        if self.txtEntreeDessert == "Entree" {
            self.ctrlEntreeDessert.selectedSegmentIndex = 0
        } else {
            self.ctrlEntreeDessert.selectedSegmentIndex = 1
        }
        //if statement for which position to put switch
    }
   
    func setupLocationAuth() {
        editName.text = user?.name
        editEmail.text = user?.email
        editPhone.text = user?.phone
        editTruckName.visibility = .gone
        lblTruckType.visibility = .gone
        foodTypePicker.visibility = .gone
        lblSubTruckType.visibility = .gone
        subFoodTypePicker.visibility = .gone
        ctrlEntreeDessert.visibility = .gone
        
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

    func grabFoodTruckFieldsForUpdate() {
        
        guard let u = user else {
            reloadSession()
            return
        }
        
        if checkFoodTruckSaveRequiredFields() {
            let nUser = User()
            nUser.uid = u.uid
            nUser.auth = u.auth
            nUser.name = editName.text!
            nUser.email = editEmail.text ?? ""
            nUser.phone = editPhone.text ?? ""
            //->
            let newTruck = Foodtruck()
            newTruck.truckName = editTruckName.text!
            newTruck.truckType = self.txtEntreeDessert
//            newTruck.foodType = editFoodType.text ?? ""
            newTruck.userId = nUser.uid
            
            if self.foodtruck.id.isEmpty {
                newTruck.id = UUID().uuidString
                self.isNewTruck = true
            } else {
                newTruck.id = self.foodtruck.id
            }
            
            guard let updatedUser = Session.updateUserForFirebase(updatedUser: nUser) else {
                //TODO: FAILED TO UPDATE PROFILE, LET USER KNOW
                return
            }
            
            if self.isNewTruck {
                Session.addFoodTruck(truck: newTruck)
            } else {
                Session.updateFoodtruck(truck: newTruck)
            }
            
            self.saveProfile(user: updatedUser)
            self.updateFoodtruckInFirebase(user: updatedUser, truck: newTruck)
            
        }
        
    }
    
    func grabLocationFieldsForUpdate() {
        
        guard let u = user else { return }
        if checkLocationSaveRequiredFields() {
            let nUser = User()
            nUser.uid = u.uid
            nUser.auth = u.auth
            nUser.name = editName.text!
            nUser.email = editEmail.text ?? ""
            nUser.phone = editPhone.text ?? ""
            guard let updatedUser = Session.updateUserForFirebase(updatedUser: nUser) else {
                //TODO: FAILED TO UPDATE PROFILE, LET USER KNOW
                return
            }
            self.saveProfile(user: updatedUser)
            
        }
        
    }
    
    func checkLocationSaveRequiredFields() -> Bool {
        if editName.text!.isEmpty {
            markNameFieldRed()
            return false
        }
        return true
    }
    
    func checkFoodTruckSaveRequiredFields() -> Bool {
        if editName.text!.isEmpty {
            markNameFieldRed()
            return false
        }
        if editTruckName.text!.isEmpty {
            markTruckNameFieldRed()
            return false
        }
        if self.txtEntreeDessert.isEmpty {
            //TODO: LET USER KNOW WHAT IS GOING ON (Defaults to Entree)
            self.txtEntreeDessert = "Entree"
        }
        return true
    }
    
    func checkFoodTruckCloseRequiredFields() -> Bool {
        guard let u = user else { return true }

        if u.name.isEmpty {
            markNameFieldRed()
            return false
        }
        
        return self.checkFoodTruckSaveRequiredFields()
    }
    
    func checkLocationCloseRequiredFields() -> Bool {
        guard let u = user else { return true }
        if u.name.isEmpty {
            markNameFieldRed()
            return false
        }
        return true
    }
    
    //----------------------------------------------------------------------------------------------------------------------------\\
    
    // -> FOOD TYPE PICKERS <- \\
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return foodTypeData.count
        } else {
            return subFoodTypeData.count
        }
    }
    
    // Set Title from Location List
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
             return "\(foodTypeData[row])"
         } else {
             return "\(subFoodTypeData[row])"
         }
    }
    
    
  //----------------------------------------------------------------------------------------------------------------------------\\
    
    
    
    
    func markNameFieldRed() {
        editName.layer.borderWidth = 1
        editName.layer.borderColor = UIColor.red.cgColor
        editName.attributedPlaceholder = NSAttributedString(string: "Name",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
    }
    
    func markTruckNameFieldRed() {
        editTruckName.layer.borderWidth = 1
        editTruckName.layer.borderColor = UIColor.red.cgColor
        editTruckName.attributedPlaceholder = NSAttributedString(string: "Truck Name",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
    }
    /*----------------------------------- DO WE STILL NEED THIS --------------------------------
    func markFoodTypeFieldRed() {
        editFoodType.layer.borderWidth = 1
        editFoodType.layer.borderColor = UIColor.red.cgColor
        editFoodType.attributedPlaceholder = NSAttributedString(string: "Food Type",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
    }
    */
    //Add location to Firebase for User
    func saveNewFoodtruckInFirebase( user : User, truck : Foodtruck){
        
        //Save Foodtruck
        ref = FireHelper.getFoodtrucksForUser(key: user.uid).child(truck.id)
        ref.setValue(self.foodtruck.convertToDictionary()) { (error:Error?, ref:DatabaseReference) in
            //Error Handling
            if let error = error {
                //Failed
                print(error)
            } else {
                //Successfully saved
                print("Success!")
                Session.updateFoodtruck(truck: self.foodtruck)
//                DispatchQueue.main.async {
//                    Session.updateFoodtruck(truck: self.foodtruck)
//                }
            }
        }
    }
    
    //Add location to Firebase for User
    func updateFoodtruckInFirebase( user : User, truck : Foodtruck){
        
        //Save Foodtruck
        ref = FireHelper.getFoodtrucksForUser(key: user.uid).child(truck.id)
        ref.updateChildValues(truck.convertToDictionary()) { (error:Error?, ref:DatabaseReference) in
            //Error Handling
            if let error = error {
                //Failed
                print(error)
            } else {
                //Successfully saved
                print("Success!")
                DispatchQueue.main.async {
                    Session.updateFoodtruck(truck: truck)
                }
            }
        }
    }
    
    //Save Profile
    func saveProfile( user : User ){
        
        DispatchQueue.main.async {
            self.present(self.loading, animated: true, completion: nil)
        }
        
        ref = FireHelper.getUsers().child(user.uid)
        ref.updateChildValues(user.convertToDictionary()) { (error:Error?, ref:DatabaseReference) in
            //Error Handling
            if let error = error {
                //TODO: NEED TO SHOW ERROR FOR THE USER AND HANDLE THIS PROPERLY!!
                print(error)
                DispatchQueue.main.async {
                    self.loading.dismiss(animated: true, completion: nil)
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                //Successfully saved
                print("User saved to Firebase")
                DispatchQueue.main.async {
                    self.loading.dismiss(animated: true, completion: nil)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
