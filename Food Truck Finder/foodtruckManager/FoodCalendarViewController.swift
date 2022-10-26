//
//  FoodCalendarViewController.swift
//  Food Truck Finder
//
//  Created by Charles Romeo on 1/9/20.
//  Copyright © 2020 Food Truck Finder Bham. All rights reserved.
//

import UIKit
import EventKit
import KDCalendar
import RealmSwift
import Firebase

class FoodCalendarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var fireHelper : FireHelper!
    var ref : DatabaseReference!
    
    @IBOutlet weak var foodCalendarView: CalendarView!
    @IBOutlet weak var foodSpotTable: UITableView!
    
//    var loading = UIAlertController()
    private var store: EKEventStore = EKEventStore()
    
    var currentSelectedDate = Date()
    
    var selectedDate = ""
    var user = User()
    var session = Session()
    var cart : Cart? = Cart()
    
    var MONTH_YEAR_DB = FireHelper.getSpotMonthYearForDBbyDate(date: Date())
    var listOfSpots = List<Spot>()
    var listOfSpotsForDay = List<Spot>()
    var locationsList = List<Location>()
    var currentLocation = Location()
    var foodtruck = Foodtruck()
    var spotsToQuery = DatabaseReference()
    var hasLoaded = false
    
    //----------------------------------------------------------------------------------------------------------------------------\\
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils().updateStatusBar(view: view)
//        self.loading = Utils().showLoadingAlert()
        //-> Session Grab
        if let sess = Session.getInstance(), let u = Session.getInstance()?.user {
            self.user = u
            self.session = sess
            if let truck = sess.foodtrucks.first {
                self.foodtruck = truck
            }
            print("No error!!")
        }else{
            dismiss(animated: true)
        }
        
        self.foodCalendarView.delegate = self
        self.foodCalendarView.dataSource = self
        
        self.foodSpotTable.delegate = self
        self.foodSpotTable.dataSource = self
        self.foodSpotTable.rowHeight = 110
        self.foodSpotTable.register(UINib(nibName: "FoodtruckTableViewCell", bundle: nil), forCellReuseIdentifier: "FoodtruckTableViewCell")
        
        //-> Request Access so Calendar will Load
//        permissionCheck()
        
        let style = CalendarView.Style()
        style.cellShape                = .bevel(8.0)
        style.cellColorDefault         = UIColor.clear
        style.cellColorToday           = UIColor.lightGray //UIColor(red:1.00, green:0.84, blue:0.64, alpha:1.00)
        style.cellSelectedTextColor    = UIColor.fLightBlue
        style.cellSelectedBorderColor  = UIColor.fLightBlue //UIColor(red:1.00, green:0.63, blue:0.24, alpha:1.00)
        style.cellEventColor           = UIColor.fOrangeOne //UIColor(red:1.00, green:0.63, blue:0.24, alpha:1.00)
        style.headerTextColor          = UIColor.white //UIColor(red: 249/255, green: 180/255, blue: 139/255, alpha: 1.0)
        style.cellTextColorDefault     = UIColor.white //UIColor(red: 249/255, green: 180/255, blue: 139/255, alpha: 1.0)
        style.cellTextColorToday       = UIColor.fDarkBlue
        style.cellTextColorWeekend     = UIColor.lightGray //UIColor(red: 237/255, green: 103/255, blue: 73/255, alpha: 1.0)
        style.cellColorOutOfRange      = UIColor(red: 249/255, green: 226/255, blue: 212/255, alpha: 1.0)
        style.weekdaysTextColor        = UIColor.white //UIColor(red: 249/255, green: 180/255, blue: 139/255, alpha: 1.0)
        style.headerBackgroundColor    = UIColor.fDarkBlue
        style.weekdaysBackgroundColor  = UIColor.fDarkBlue
        style.firstWeekday             = .sunday
        style.locale                   = Locale(identifier: "en_US")
        
        style.cellFont = UIFont(name: "Helvetica", size: 20.0) ?? UIFont.systemFont(ofSize: 20.0)
        style.headerFont = UIFont(name: "Helvetica", size: 20.0) ?? UIFont.systemFont(ofSize: 20.0)
        style.weekdaysFont = UIFont(name: "Helvetica", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
        
        foodCalendarView.style = style
        foodCalendarView.direction = .horizontal
        foodCalendarView.multipleSelectionEnable = false
        foodCalendarView.marksWeekends = true
        foodCalendarView.backgroundColor = UIColor.fDarkBlue
        
        self.grabSpotsFromFirebase()
        
        self.foodCalendarView.selectDate(self.currentSelectedDate)
    }
    
    private func requestAccessCalendars() {
        store.requestAccess(to: .event) { [weak self] (accessGranted, error) in
            if accessGranted {
                self?.store = EKEventStore() // <- second instance
                self?.store.refreshSourcesIfNecessary()
                self?.grabSpotsFromFirebase()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let today = Date()
        self.foodCalendarView.setDisplayDate(today)
    }
    
    //----------------------------------------------------------------------------------------------------------------------------\\
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listOfSpotsForDay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.listOfSpotsForDay[indexPath.row] as Spot
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodtruckTableViewCell") as! FoodtruckTableViewCell
        cell.setupTableCell(spot: row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Alert to add to cart?
        Utils().showSpotDetailsAlert(context: self, spot: self.listOfSpotsForDay[indexPath.row], isAdd: true)
    }
    
    //-> Update Spot to "Pending"
    func updateSpotAsPending( spot : Spot ){
        guard let truck = self.foodtruck.truckName else { return }
        guard let updatedSpot = Session.updateSpotForFirebase(spot: spot, status: FireHelper.PENDING,
                                                              assignedTruckUid: user.uid,
                                                              assignedTruckName: truck) else { return }
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
                print("Failed to updated spot as pending, \(error)")
                DispatchQueue.main.async {
                    Utils().showServerUnavailableAlert(context: self)
                }
            } else {
                //Successfully saved
                print("Spot pending in Firebase")
            }
        }
    }
    //----------------------------------------------------------------------------------------------------------------------------\\
    //-> LOAD LISTS OF SPOTS FOR SELECTED DAY
    func loadSpotListForDay(date: Date, events: [CalendarEvent]) {
        self.listOfSpotsForDay.removeAll()
        self.listOfSpotsForDay = List<Spot>()
        for event in events {
            print("\t\"\(event.title)\" - Starting at:\(event.startDate)")
            for spot in self.listOfSpots {
                //If Event Title equals Spot Manager (this is set this way)
                let c = DateUtils.convertDateToString(dateObject: event.startDate)
                //If the dates match
                if spot.date?.starts(with: c) ?? false {
                    if !self.listOfSpotsForDay.contains(spot){
                        self.listOfSpotsForDay.append(spot)
                    }
                }
            }
        }
        self.currentSelectedDate = date
        self.foodSpotTable.reloadData()
    }
    
    //-> Match event title/id for spot id
    func matchEventToSpot(id : String) -> Spot? {
        for spot in self.listOfSpots {
            if let spotid = spot.id {
                if id == spotid {
                    return spot
                }
            }
        }
        return nil
    }
    
    //-> Add Spot To Calendar
    func addSpotToCalendar(spot: Spot){
        if let s = spot.id, let d = spot.date {
            let f = DateUtils.convertToDate(dateUTC: d)
            if let fd = f {
                //TODO: WE NEED TO SET THE UUID AS THE EVENT TITLE
                //-> WHEN WE SHOW THE LIST BELOW, WE WILL MATCH THE UUID'S AND SHOW THE FULL SPOT IN THE LIST
                self.foodCalendarView.addEvent(s, date: fd)
            }
        }
        self.foodCalendarView.reloadData()
    }
    
    //-> RESET CALENDAR EVENTS
    func resetCalendarEvents() {
        self.foodCalendarView.events.removeAll()
        self.foodCalendarView.reloadData()
    }
    
    func addDays(days:Int, date:Date) -> Date? {
        let daysToAdd = days
        var dateComponent = DateComponents()
        dateComponent.day = daysToAdd
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: date)
        return futureDate
    }
    
    func addDays(days:Int, date:String) -> String? {
        
        guard let tempDate = DateUtils.finderStringToDate(dateStr: date) else {
            return date
        }
        let daysToAdd = days
        var dateComponent = DateComponents()
        dateComponent.day = daysToAdd
        guard let futureDate = Calendar.current.date(byAdding: dateComponent, to: tempDate) else {
            return date
        }
        
        return DateUtils.convertDateToString(dateObject: futureDate)
    }
    
    //-> Grab Locations from Firebase
    func grabSpotsFromFirebase() {
        
//        DispatchQueue.main.async {
//            self.present(self.loading, animated: true, completion: nil)
//        }
        
        self.resetCalendarEvents()
        self.listOfSpotsForDay.removeAll()
        self.listOfSpots.removeAll()
        
        if !self.hasLoaded {
            self.spotsToQuery = FireHelper.getSpotsForMonth(month: self.MONTH_YEAR_DB)
            self.hasLoaded = true
        }
        
        self.spotsToQuery.observe(.value, with: { (snapshot) in
            
            self.listOfSpotsForDay.removeAll()
            self.listOfSpots.removeAll()
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                
                guard let map = rest.value as? NSObject else { return }
                
                let newSpot = ParseSpot.parseSpot(map: map)
                /*
                if newSpot.status == FireHelper.PENDING || newSpot.status == FireHelper.BOOKED {
                    continue
                }
                */
//                if newSpot.foodType != self.foodtruck.truckType { continue }
                if self.isOldSpot(date: newSpot.date!) { continue }
                self.listOfSpots.append(newSpot)
                self.addSpotToCalendar(spot: newSpot)
            }
            
            DispatchQueue.main.async {
                self.hasLoaded = false
                self.foodCalendarView.selectDate(self.currentSelectedDate)
                self.foodSpotTable.reloadData()
//                self.loading.dismiss(animated: true, completion: nil)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
}

//----------------------------------------------------------------------------------------------------------------------------\\
extension FoodCalendarViewController: CalendarViewDelegate {
    func calendar(_ calendar: CalendarView, didScrollToMonth date: Date) {
        print(self.foodCalendarView.selectedDates)
        
        if hasLoaded { return }
        //GET Spots for Current Month
        guard let newDate = date.addOneDay() else { return }
        let newMonth = FireHelper.getSpotMonthYearForDBbyDate(date: newDate)
        if self.MONTH_YEAR_DB == newMonth { return }
        self.MONTH_YEAR_DB = newMonth
        self.grabSpotsFromFirebase()
    }
    
    func calendar(_ calendar: CalendarView, didSelectDate date: Date, withEvents events: [CalendarEvent]) {
        print("Did Select: \(date) with \(events.count) events")
        self.loadSpotListForDay(date: date, events: events)
    }
    
    func calendar(_ calendar: CalendarView, canSelectDate date: Date) -> Bool {
        true
    }
    
    func calendar(_ calendar: CalendarView, didDeselectDate date: Date) {
        print("Did Deselect: \(date) with events")
        
        guard let tempDate = addDays(days: 1, date: DateUtils.convertDateToString(dateObject: date)) else {
            return
        } 
        
        //match spot date in listofday and remove it
        for (i,num) in self.listOfSpotsForDay.enumerated().reversed() {
            guard let tDate = num.date else {
               return
            }
            if tDate.starts(with: tempDate) {
                self.listOfSpotsForDay.remove(at: i)
            }
        }
        self.foodSpotTable.reloadData()
    }
    
    func calendar(_ calendar: CalendarView, didLongPressDate date: Date, withEvents events: [CalendarEvent]?) {
        print("Did Select: \(date) with events")
    }
    
    //-> Sorting
    func isOldSpot(date:String) -> Bool {
        //format dates
        if DateUtils.dateIsOlderThanToday(possibleOldDate: date) {
            return true
        }
        return false
    }
    
}

//----------------------------------------------------------------------------------------------------------------------------\\
extension FoodCalendarViewController: CalendarViewDataSource {
    func headerString(_ date: Date) -> String? {
        /** This causes a bug if the date is the last day of the month, it will return Next Month since we add one day**/
        guard let a = date.addOneDay() else { return "Unknown Month" }
        return DateUtils.getMonth(monthInt: a.get(.month))
    }
    
    func startDate() -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = -1
        let today = Date()
        let threeMonthsAgo = self.foodCalendarView.calendar.date(byAdding: dateComponents, to: today)!
        return threeMonthsAgo
    }
    
    func endDate() -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = 12
        let today = Date()
        let twoYearsFromNow = self.foodCalendarView.calendar.date(byAdding: dateComponents, to: today)!
        return twoYearsFromNow
    }
}
