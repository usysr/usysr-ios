//
//  Utils.swift
//  Food Truck Finder
//
//  Created by Charles Romeo on 5/9/20.
//  Copyright © 2020 Food Truck Finder Bham. All rights reserved.
//

import Foundation
import UIKit

class Utils {
    
    func isOldSpot(date:String) -> Bool {
        //format dates
        if DateUtils.dateIsOlderThanToday(possibleOldDate: date) {
            return true
        }
        return false
    }
    
    func showSpotDetailsAlert(context:UIViewController, spot:Spot) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "spotDetailsAlert") as! SpotDetailsAlertController
        myAlert.spot = spot
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        context.present(myAlert, animated: true, completion: nil)
    }
    
    func showSpotDetailsAlert(context:FoodCalendarViewController, spot:Spot, isAdd:Bool) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "spotDetailsAlert") as! SpotDetailsAlertController
        myAlert.spot = spot
        myAlert.isAdd = true
        myAlert.foodCalendarVC = context
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        context.present(myAlert, animated: true, completion: nil)
    }
    
    func showSpotDetailsAlert(context:FoodCartViewController, spot:Spot, isRemove:Bool) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "spotDetailsAlert") as! SpotDetailsAlertController
        myAlert.spot = spot
        myAlert.isRemove = true
        myAlert.foodCartVC = context
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        context.present(myAlert, animated: true, completion: nil)
    }
    
    func showSpotDetailsAlert(context:LocCalendarViewController, spot:Spot) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "spotDetailsAlert") as! SpotDetailsAlertController
        myAlert.spot = spot
//        myAlert.isRemove = true
//        myAlert.foodCartVC = context
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        context.present(myAlert, animated: true, completion: nil)
    }
    
    func showAlertCancelOnly(context:UIViewController, title:String, message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Okay", style: .destructive, handler: nil)
        alert.addAction(cancelAction)
        context.present(alert, animated: true, completion: nil)
        
    }
    
    //UIVIEWCONTROLLER LOADING ALERT
    func showLoadingAlert() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        return alert
    }
    
    
    func showServerUnavailableAlert(context:UIViewController) {
      let alert = UIAlertController(title: "Uh Oh", message: "Unable to reach the server, please try again later.", preferredStyle: .alert)
      let cancelAction = UIAlertAction(title: "Okay", style: .destructive, handler: nil)
      alert.addAction(cancelAction)
      context.present(alert, animated: true, completion: nil)
    }
    
    
    func updateStatusBar(view:UIView){
        if #available(iOS 13.0, *) {
            let app = UIApplication.shared
            let statusBarHeight: CGFloat = app.statusBarFrame.size.height
            
            let statusbarView = UIView()
            statusbarView.backgroundColor = UIColor.fDarkBlue
            view.addSubview(statusbarView)
          
            statusbarView.translatesAutoresizingMaskIntoConstraints = false
            statusbarView.heightAnchor
                .constraint(equalToConstant: statusBarHeight).isActive = true
            statusbarView.widthAnchor
                .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
            statusbarView.topAnchor
                .constraint(equalTo: view.topAnchor).isActive = true
            statusbarView.centerXAnchor
                .constraint(equalTo: view.centerXAnchor).isActive = true
          
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = UIColor.fDarkBlue
        }
    }
    
}
