//
//  ViewController.swift
//  USYSR
//
//  Created by Chazz Romeo & Michael Cather on 12/2/19
//  Copyright © 2020 USYSR. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase
import FirebaseDatabase
import KDCalendar

class AuthController: UIViewController {
    
    var fireHelper : FireHelper!
    var ref : DatabaseReference!
    var loading = UIAlertController()

    let providers: [FUIAuthProvider] = [
      FUIGoogleAuth(),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Starting AuthController")
        
        self.loading = Utils().showLoadingAlert()
        //Show Loading 
        if Session.isLogged(){
            if let session = Session.getInstance(), let user = session.user {
                //Stay safe, stay here.
                if user.auth == FireHelper.WAITING {
                    grabProfile(user: user)
                } else { self.navigateUser(user: user) }
                print("No error!!")
            }else{
                dismiss(animated: true)
            }
        } else {
            self.performSegue(withIdentifier: "userBasic", sender: nil)
        
            
            // Going to use below code on a button in new page
            
            /*
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
            */
        }
             
    }
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return LoginViewController(authUI: authUI)
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
    
    func navigateUser(user : User){
        //-> FoodTruck Dashboard
        if user.auth == FireHelper.FOODTRUCK_MANAGER {
            print("Segue to Foodtruck -> AuthController")
            guard let selfRef = self.ref else {
                performSegue(withIdentifier: "ToFoodTruck", sender: nil)
                return
            }
            selfRef.removeAllObservers()
            performSegue(withIdentifier: "ToFoodTruck", sender: nil)
        }

        //-> Location Manager Dashboard
        if user.auth == FireHelper.LOCATION_MANAGER {
            print("Segue to Location -> AuthController")
            guard let selfRef = self.ref else {
                performSegue(withIdentifier: "ToLocation", sender: nil)
                return
            }
            selfRef.removeAllObservers()
            performSegue(withIdentifier: "ToLocation", sender: nil)
        }
        
        //-> Waiting Dashboard //TODO:
        if user.auth == FireHelper.WAITING {
            print("Segue to User Dashboard, WAITING -> AuthController")
            performSegue(withIdentifier: "ToUserDash", sender: nil)
            return
        }
        
    }
    
}

extension AuthController: FUIAuthDelegate {
    
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
    }
    
}

