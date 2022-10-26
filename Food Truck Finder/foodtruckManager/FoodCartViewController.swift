//
//  FoodCartViewController.swift
//  Food Truck Finder
//
//  Created by Charles Romeo on 1/9/20.
//  Copyright © 2020 FoodTruck Finder. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import RealmSwift

//-> TODO: add check to verify user is ready for checkout
//          check if the cart is empty

class FoodCartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var user : User = User()
    var session = Session()
    var totalCost = "0.00"
    var fireHelper : FireHelper!
    var ref : DatabaseReference!
    var temp = List<Spot>()
    var listOfCartSpots = List<Spot>()
    
    var loading = UIAlertController()
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var lblTotalCost: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnCheckoutC: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    @IBAction func btnCheckOut(_ sender: UIButton) {
        
        if (self.totalCost.isEmpty || self.totalCost == "0.00" ||  self.totalCost == "" ) {
            Utils().showAlertCancelOnly(context: self, title: "Empty Cart", message: "Please add a spot to your cart from the calendar.")
        } else {
            let alert = UIAlertController(title: "Checkout", message: "Are you sure you want to checkout? Total: $\(self.totalCost)", preferredStyle: .alert)
            let acceptAction = UIAlertAction(title: "Pay", style: .destructive, handler: acceptCheckout)
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            alert.addAction(acceptAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func acceptCheckout(action:UIAlertAction){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let checkoutVC = storyboard.instantiateViewController(withIdentifier: "CheckoutViewController") as! CheckoutViewController
        checkoutVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        checkoutVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        checkoutVC.checkoutVC = self
        checkoutVC.listOfSpotsToBuy = self.listOfCartSpots
        checkoutVC.amount = self.totalCost
        checkoutVC.user = self.user
        self.present(checkoutVC, animated: true, completion: nil)
        print("Checkout Pressed")
    }
    
    func buttonDesignSetup(){
        btnCheckoutC.fDesignCartCheckout()
//        lblTotalCost.textColor = UIColor.fDarkBlue
    }
    
    //onCreate
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDesignSetup()
        Utils().updateStatusBar(view: view)
        self.loading = Utils().showLoadingAlert()

        setupDisplay()
        
        // TableView Setup
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 85
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "CartTableViewCell", bundle: nil), forCellReuseIdentifier: "CartTableViewCell")
        tableView.addSubview(refreshControl)
        
        refreshControl.attributedTitle = NSAttributedString(string: "refreshing")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        doRefresh()
        print("showing")
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("destroying")
    }
    //Pull to Refresh
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        doRefresh()
        self.refreshControl.endRefreshing()
    }
    
    func doRefresh() {
       // Code to refresh table view
        setupDisplay()
        tableView.reloadData()
    }
    
    func setupDisplay() {
        //-> Session Grab
        if let sess = Session.getInstance(), let u = Session.getInstance()?.user {
            self.user = u
            self.session = sess
            self.listOfCartSpots = self.sortCartList(spots: sess.spots)
            if let total = Session.calculateTotalCost(spots: self.listOfCartSpots) {
                self.totalCost = total
                self.lblTotalCost.fTotalCost(totalCost: String(self.totalCost))
            }
            print("No error!!")
        }else{
            dismiss(animated: true)
        }
    }
    
    func sortCartList(spots:List<Spot>) -> List<Spot> {
        let list = List<Spot>()
        for s in spots {
            if s.status == FireHelper.PENDING {
                list.append(s)
            }
        }
        return list
    }
    
    //TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listOfCartSpots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let spot = self.listOfCartSpots[indexPath.row] as Spot
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartTableViewCell") as! CartTableViewCell
        cell.lblSpotName.text = spot.locationName!
        cell.separatorInset = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        guard let price = spot.price else { return cell }
        cell.lblSpotCost?.fPrice(price: price)
        guard let date = spot.date else { return cell }
        if let mealTime = spot.mealTime {
            cell.lblSpotDate?.fDate(date: date, mealTime: mealTime) }
        else {
            cell.lblSpotDate?.fDate(date: date)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Alert to add to cart?
        Utils().showSpotDetailsAlert(context: self, spot: self.listOfCartSpots[indexPath.row], isRemove: true)
    }
    
    //-> Update Spot to "Available"
    func updateSpotAsAvailable( spot : Spot ){
        //Show Loading
        self.present(self.loading, animated: true, completion: nil)
        
        guard let updatedSpot = Session.updateSpotForFirebase(spot: spot, status: FireHelper.AVAILABLE, assignedTruckUid: "", assignedTruckName: "") else {
            return
        }
        
        guard let id = updatedSpot.id else { return }
        
        //spot date string to date
        guard let date = updatedSpot.date else { return }
        guard let toDateObj = DateUtils.convertStringToDateObjectForFirebaseDB(dateStr: date) else { return }
        let MONTH_YEAR_DB = FireHelper.getSpotMonthYearForDBbyDate(date: toDateObj)
        //date to MONTH_YEAR_DB
        
        ref = FireHelper.getSpotsForMonth(month: MONTH_YEAR_DB).child(id)
        ref.setValue(updatedSpot.convertToDictionary()) { (error:Error?, ref:DatabaseReference) in
            //Error Handling
            if let error = error {
                //TODO: NEED TO SHOW ERROR FOR THE USER AND HANDLE THIS PROPERLY!!
                let alert = UIAlertController(title: "Uh Oh", message: "Unable to reach the server, please try again later.", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Okay", style: .destructive, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                print("Failed to set spot to pending, \(error)")
            } else {
                //Successfully saved
                //->Remove Spot From Cart
                Session.removeSpotFromCart(spot: spot)
                //reload self spots
                self.setupDisplay()
                self.tableView.reloadData()
                print("Spot available in Firebase")
            }
        }
        //Dismiss Loading
        self.loading.dismiss(animated: true, completion: nil)
    }
   

}
