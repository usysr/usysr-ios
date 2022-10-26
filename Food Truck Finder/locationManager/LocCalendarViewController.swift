//
//  CalendarViewController.swift
//  Food Truck Finder
//
//  Created by Charles Romeo on 1/9/20.
//  Copyright © 2020 FoodTruck Finder. All rights reserved.
//

import UIKit
import EventKit
import KDCalendar
import RealmSwift
import FirebaseDatabase

class LocCalendarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
   
    @IBOutlet weak var btnAddRef: UIButton!
    @IBOutlet weak var spotTableView: UITableView!
    @IBOutlet weak var locCalendarView: CalendarView!
    @IBOutlet weak var locPicker: UIPickerView!
    
    var loading = UIAlertController()
//    private var store: EKEventStore = EKEventStore()
    var selectedDatesList = List<String>()
    var user = User()
    let today = Date()
    var session = Session()
    // 2020-03-16 23:00:00 +0000
    // 12:00:00 -> Lunch
    // 17:00:00
    var currentSelectedDate = Date()
    var txtLocationName = ""
    let lunchString = " 12:00:00"
    let dinnerString = " 17:00:00"
    var MONTH_YEAR_DB = FireHelper.getSpotMonthYearForDBbyDate(date: Date())
    var listOfSpots = List<Spot>()
    var listOfSpotsForDay = List<Spot>()
    var locationsList = List<Location>()
    var currentLocation = Location()
    var startLocationString = ""
    var spotsToQuery = DatabaseReference()
    var hasLoaded = false

    //BTN Action
    @IBAction func btnAddSpots(_ sender: Any) {
        if self.hasOldDateSelected() {
            //show dialog
            let alert = UIAlertController(title: "Old Date(s)", message: "One or more date(s) are in the past, please deselect all old dates.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Okay", style: .destructive, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        } else { addSpots() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupDisplay()
    }
    
    //onCreate
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func reloadSession() {
        if let sess = Session.getInstance(), let u = Session.getInstance()?.user {
            self.user = u
            self.session = sess
            self.locationsList = session.locations
            //test this
            if self.locationsList.count > 0 {
                guard let curLoc = self.locationsList[0]["locationName"] as? String else {
                    self.grabLocationsFromFirebase(user: u)
                    return
                }
                self.txtLocationName = curLoc
                self.startLocationString = curLoc
                self.currentLocation = self.locationsList[0]
                self.grabSpotsFromFirebaseByLocation(locationName: self.startLocationString)
            }
            self.locPicker.reloadAllComponents()
            print("No error!!")
        }else{
            dismiss(animated: true)
        }
    }
    
    func setupDisplay() {
        Utils().updateStatusBar(view: view)
        self.loading = Utils().showLoadingAlert()

        self.reloadSession()
        //-> Request Access so Calendar will Load
        //        permissionCheck()

        locPicker.delegate = self
        locPicker.dataSource = self
        locPicker.backgroundColor = UIColor.fDarkBlue
        btnAddRef.fCircleDesign()

        self.spotTableView.delegate = self
        self.spotTableView.dataSource = self
        self.spotTableView.rowHeight = 110
        self.spotTableView.register(UINib(nibName: "FoodtruckTableViewCell", bundle: nil), forCellReuseIdentifier: "FoodtruckTableViewCell")

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

        locCalendarView.style = style
        locCalendarView.dataSource = self
        locCalendarView.delegate = self
        locCalendarView.direction = .horizontal
        locCalendarView.multipleSelectionEnable = true
        locCalendarView.marksWeekends = true
        locCalendarView.backgroundColor = UIColor.fDarkBlue
        
        self.locCalendarView.setDisplayDate(self.today)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.locCalendarView.events.removeAll()
        self.locCalendarView.setDisplayDate(self.today)
    }
    
    func deSelectedAllDates() {
        if !self.locCalendarView.selectedDates.isEmpty {
            for date in self.locCalendarView.selectedDates {
                self.locCalendarView.deselectDate(date)
            }
        }
    }
    
    func selectToday() { self.locCalendarView.setDisplayDate(self.today) }
    
    func reloadCalendar() {
        self.locCalendarView.events.removeAll()
        if self.locationsList.count > 0 {
            self.grabSpotsFromFirebaseByLocation(locationName: self.locationsList[0]["locationName"] as! String)
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
        if let locName = locationsList[row]["locationName"] as? String {
            //Reload Events based only on this location
            self.deSelectedAllDates()
            self.txtLocationName = locName
            self.currentLocation = locationsList[row]
            self.grabSpotsFromFirebaseByLocation(locationName: locName)
            self.listOfSpotsForDay.removeAll()
            self.locCalendarView.setDisplayDate(self.today)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        guard let str = locationsList[row]["locationName"] as? String else { return nil }
        let attributedString = NSAttributedString(string: str, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        return attributedString
    }
//----------------------------------------------------------------------------------------------------------------------------\\
        
    // -> SPOT LIST TABLE VIEW <- \\
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
        Utils().showSpotDetailsAlert(context: self, spot: self.listOfSpotsForDay[indexPath.row])
    }
}

//----------------------------------------------------------------------------------------------------------------------------\\

    // -> CALENDAR <- \\
    extension LocCalendarViewController: CalendarViewDataSource {
        func headerString(_ date: Date) -> String? {
            guard let a = date.addOneDay() else { return "Unknown Month" }
            let currentMonth = DateUtils.getMonth(monthInt: a.get(.month))
            return currentMonth
        }
        
          func startDate() -> Date {
              var dateComponents = DateComponents()
              dateComponents.month = -1
              let today = Date()
              let threeMonthsAgo = self.locCalendarView.calendar.date(byAdding: dateComponents, to: today)!
              return threeMonthsAgo
          }
          func endDate() -> Date {
              var dateComponents = DateComponents()
              dateComponents.month = 12
              let today = Date()
              let twoYearsFromNow = self.locCalendarView.calendar.date(byAdding: dateComponents, to: today)!
              return twoYearsFromNow
          }
    }

    extension LocCalendarViewController: CalendarViewDelegate{
        
        func calendar(_ calendar: CalendarView, didScrollToMonth date: Date) {
            print(self.locCalendarView.selectedDates)
            
            if hasLoaded { return }
            //GET Spots for Current Month
            guard let newDate = date.addOneDay() else { return }
            let newMonth = FireHelper.getSpotMonthYearForDBbyDate(date: newDate)
            if self.MONTH_YEAR_DB == newMonth { return }
            self.MONTH_YEAR_DB = newMonth
            self.grabSpotsFromFirebaseByLocation(locationName: self.txtLocationName)
        }
        
        // -> SELECT DATE
        func calendar(_ calendar: CalendarView, didSelectDate date: Date, withEvents events: [CalendarEvent]) {
            print("Did Select: \(date) with \(events.count) events")
            if let fd = addDays(days: 1, date: date) {
                self.selectedDatesList.append(DateUtils.convertDateToString(dateObject: fd))
            }
            self.loadSpotListForDay(date: date, events: events)
        }
        
        // -> DE-SELECT DATE
        func calendar(_ calendar: CalendarView, didDeselectDate date: Date) {
            print("Did Deselect: \(date) with events")
            
            guard let tempDate = addDays(days: 1, date: DateUtils.convertDateToString(dateObject: date)) else {
                return
            }
            // -> Handling Selected Dates for making spot
            var i = 0
            var f = 0
            for d in self.selectedDatesList {
                if tempDate == d {
                    f = i
                    break
                }
                i = i + 1
            }
            self.selectedDatesList.remove(at: f)
            
            //match spot date in listofday and remove it
            print("DeSelect Before -> \(self.listOfSpotsForDay.count)")
            for (i,num) in self.listOfSpotsForDay.enumerated().reversed() {
                guard let numDate = num.date else { return }
                
                if numDate.starts(with: tempDate) {
                    self.listOfSpotsForDay.remove(at: i)
                }
            }
            self.spotTableView.reloadData()
        }
        
        func calendar(_ calendar: CalendarView, canSelectDate date: Date) -> Bool {
            return true
        }
        
        // LONG PRESS ON DATE
        func calendar(_ calendar: CalendarView, didLongPressDate date: Date, withEvents events: [CalendarEvent]?) {
//            self.addSpots(self)
        }
//----------------------------------------------------------------------------------------------------------------------------\\
        
        
        // -> HELPER METHODS <- \\
        
        //RESET CALENDAR EVENTS
        func resetCalendarEvents() {
            self.locCalendarView.events.removeAll()
            self.locCalendarView.reloadData()
        }
        
        func addSpotToCalendar(spot: Spot){
            guard let spotDate = spot.date else { return }
            if spot.spotManager == user.name {
                let f = DateUtils.convertToDate(dateUTC: spotDate)
                if let fd = f {
                    //TODO: WE NEED TO SET THE UUID AS THE EVENT TITLE
                    //-> WHEN WE SHOW THE LIST BELOW, WE WILL MATCH THE UUID'S AND SHOW THE FULL SPOT IN THE LIST
                    guard let id = spot.id else {
                        return
                    }
                    //TODO: ADDING EVENT HERE
                    self.locCalendarView.addEvent(id, date: fd)
                }
            }
            self.locCalendarView.reloadData()
        }
        
        func hasOldDateSelected() -> Bool {
            for date in self.selectedDatesList {
                if DateUtils.dateIsOlderThanToday(possibleOldDate: date) {
                    return true
                }
            }
            return false
        }
        
        // ADD NEW SPOT METHOD FOR BUTTON
        func addSpots() {
            
            if self.selectedDatesList.count > 0 {
                print(self.locCalendarView.selectedDates)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myAlert = storyboard.instantiateViewController(withIdentifier: "locationAlert") as! CreateSpotViewController
                myAlert.currentDateString = DateUtils.convertDateToString(dateObject: self.currentSelectedDate)
                myAlert.calDelegate = self
                myAlert.selectedDatesList = self.selectedDatesList
                myAlert.txtLocationName = self.txtLocationName
                myAlert.finalLocation = self.currentLocation
                myAlert.listOfSpots = self.listOfSpots
                myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                self.present(myAlert, animated: true, completion: nil)
            } else {
                //show dialog
                let alert = UIAlertController(title: "No Selected Date", message: "Please select a date.", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Okay", style: .destructive, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
           
        }
        
        //LOAD LISTS OF SPOTS FOR SELECTED DAY
        func loadSpotListForDay(date: Date, events: [CalendarEvent]) {
            print("Select Before -> \(self.listOfSpotsForDay.count)")
            for event in events {
                print("\t\"\(event.title)\" - Starting at:\(event.startDate)")
                for spot in self.listOfSpots {
                    //If Event Title equals Spot Manager (this is set this way)
                    if event.title == spot.id {
                        let c = DateUtils.convertDateToString(dateObject: event.startDate)
                        //If the dates match
                        guard let spotDate = spot.date else { return }
                        if spotDate.starts(with: c) {
                            if spot.spotManager == user.name {
                                if !self.listOfSpotsForDay.contains(spot){
                                    self.listOfSpotsForDay.append(spot)
                                }
                            }
                        }
                    }
                }
                print("Select Before -> \(self.listOfSpotsForDay.count)")
            }
            if let fd = addDays(days: 1, date: date) {
                self.currentSelectedDate = fd
            }
            self.spotTableView.reloadData()
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
        
        //Grab Locations from Firebase
        func grabSpotsFromFirebaseByLocation(locationName : String) {
            
            self.resetCalendarEvents()
            self.listOfSpotsForDay.removeAll()
            self.listOfSpots.removeAll()
            
            if !hasLoaded {
                self.spotsToQuery = FireHelper.getSpotsForMonth(month: self.MONTH_YEAR_DB)
                self.hasLoaded = true
            }
            
            self.spotsToQuery.queryOrdered(byChild:"locationName")
                .queryEqual(toValue:locationName).observe(.value, with: { (snapshot) in
                let enumerator = snapshot.children
                self.listOfSpotsForDay.removeAll()
                self.listOfSpots.removeAll()
                while let rest = enumerator.nextObject() as? DataSnapshot {
                    guard let map = rest.value as? NSObject else { return }
                    let newSpot = ParseSpot.parseSpot(map: map)
                    if newSpot.status == FireHelper.PENDING || newSpot.status == FireHelper.BOOKED {
                        continue
                    }
                    self.listOfSpots.append(newSpot)
                    self.addSpotToCalendar(spot: newSpot)
                    print("Added Spot: \(newSpot)")
                }
                    
                DispatchQueue.main.async {
                    self.hasLoaded = false
                    self.spotTableView.reloadData()
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }

        }
        
        
         //Grab Locations from Firebase
        func grabLocationsFromFirebase( user : User ){
            
            let temp = Database.database().reference()
            temp.child("Profiles").child("locations").child(user.uid)
                .observeSingleEvent(of: .value, with: { (snapshot) in
                
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
