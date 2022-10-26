//
//  DateUtils.swift
//  Food Truck Finder
//
//  Created by Charles Romeo on 3/1/20.
//  Copyright © 2020 Food Truck Finder. All rights reserved.
//

import UIKit
import Foundation

class DateFormats {
    
    // 2020-03-16 23:00:00 +0000
    
    static let defaultFormatTimeUTC_original = "yyyy-MM-dd HH:mm:ss"
    static let defaultFormatTimeUTC = "yyyy-MM-dd"
    static let defaultFormatUTC = "yyyy-MM-dd HH:mm"
    static let defaultFormatDate = "MMM dd,yyyy"
    static let defaultFormatDateDay = "EEEE, MMM dd,yyyy"
    static let defaultFormatDateTime = "MMM dd,yyyy HH:mm"
    static let defaultFormatDay = "EEEE"
    static let defaultFormatTime = "HH:mm"
    static let spotMonthDB = "MMMyyyy"
    
}

class DateUtils: NSObject {
    
    static let defaultFormatUTC_original = "yyyy-MM-dd HH:mm:ss"
    static let defaultFormatUTC = "yyyy-MM-dd"
    static let defaultFormatDate = "MMM dd,yyyy"
    static let defaultFormatDateTime = "MMM dd,yyyy HH:mm"
    static let defaultFormatTime = "HH:mm"
    
    static let format_FULLDAY = "EEEE"
    static let format_FULLDAY_MONTH_DAY_YEAR = "EEEE, MMMM dd yyyy"
    static let format_MONTH_DAY_YEAR = "MMMM dd yyyy"
    static let format_FULLDAY_MONTH_DAY = "EEEE, MMMM dd"
    static let format_MONTH_DAY = "MMMM dd"
    static let format_YEAR_MONTH_DAY = "yyyy-MM-dd"
    static let format_DATE_TIME = "dd-MM-yyyy hh:mm"
    static let format_DATE_MILITARY_TIME = "dd-MM-yyyy HH:mm"
    
    static let spotMonthDB = "MMMyyyy"
    
    static func isLessThan24(components: DateComponents) -> Bool {
        
        guard components.year! == 0 else { return false }
        guard components.month! == 0 else { return false }
        guard components.day! == 0 else { return false }
        guard components.hour! <= 24  else { return false }
        
        return true
    }
    
    static func isLessThan60seconds(components: DateComponents) -> Bool {
        
        guard components.year! >= 0 else { return false }
        guard components.month! >= 0 else { return false }
        guard components.day! >= 0 else { return false }
        guard components.hour! >= 0  else { return false }
        guard components.minute! >= 0  else { return false }
        
        return true
    }
    
    static func numberOfDays(components: DateComponents) -> Int {
        return components.day!
    }
    
    public static func getCalendarObject()-> Calendar{
        return Calendar.current
    }
    
    //Int: -> Days between two events
    public static func daysBetweenDates(startDate: String, endDate: String) -> Int
    {
        
        guard let date1 = convertStringToDateObjectByScheme(dateStr: startDate,
                                                            fromFormat: format_YEAR_MONTH_DAY,
                                                            toFormat: format_YEAR_MONTH_DAY)
            else { return 0 }
        
        guard let date2 = convertStringToDateObjectByScheme(dateStr: endDate,
                                                            fromFormat: format_YEAR_MONTH_DAY,
                                                            toFormat: format_YEAR_MONTH_DAY)
            else { return 0 }
    
        return Calendar.current.dateComponents([.day], from: date1, to: date2).day!
    }
    
    //Bool: -> Do Dates Match?
    public static func datesDoMatch(dateOne: String, dateTwo: String) -> Bool
    {
        
        guard let date1 = convertStringToDateObjectByScheme(dateStr: dateOne,
                                                            fromFormat: format_YEAR_MONTH_DAY,
                                                            toFormat: format_YEAR_MONTH_DAY)
            else { return false }
        
        guard let date2 = convertStringToDateObjectByScheme(dateStr: dateTwo,
                                                            fromFormat: format_YEAR_MONTH_DAY,
                                                            toFormat: format_YEAR_MONTH_DAY)
            else { return false }
    
        return (date1 == date2)
    }
    
    //Bool: -> Do Dates Match?
    public static func dateIsOlderThanToday(possibleOldDate: String) -> Bool {
       let todayDate = DateUtils.convertDateToString(dateObject: Date())
       guard let today = convertStringToDateObjectByScheme(dateStr: todayDate,
                                                           fromFormat: format_YEAR_MONTH_DAY,
                                                           toFormat: format_YEAR_MONTH_DAY)
           else { return false }
       
       guard let pOldDate = convertStringToDateObjectByScheme(dateStr: possibleOldDate,
                                                           fromFormat: format_YEAR_MONTH_DAY,
                                                           toFormat: format_YEAR_MONTH_DAY)
           else { return false }

       return ( pOldDate < today)
    }
    
//    static func addDaysToDate() -> String {
//
//    }

    func getFDate(date:String, mealTime:String) -> String {
        let d = DateUtils.convertStringDateToScheme(dateStr: date, toFormat: DateUtils.format_FULLDAY_MONTH_DAY_YEAR)
        return "\(mealTime), \(d)"
    }
    
    static func isComingThisWeek(components: DateComponents) -> Bool {
        guard components.day!<6 && components.day!>=0
            else {
                return false
        }
        return true
    }
    //IS: -> Event is this week
    public static func isComingThisWeek(dateString: String) -> Bool{
        let dateRangeStart = Date()
        if let dateEnd = self.convertToDate(dateUTC: dateString) {
            let components = Calendar.current.dateComponents([.day], from: dateRangeStart, to: dateEnd)
            if isComingThisWeek(components: components) {
                return true
            }
        }
        return false
    }
    
    //IS: -> Event is today
    static func isLessThan24(dateUTC: String) -> Bool{
        let dateRangeStart = Date()
        if let dateEnd = self.convertToDate(dateUTC: dateUTC) {
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dateRangeStart, to: dateEnd)
            if isLessThan24(components: components) {
                return true
            }
        }
        return false
    }
    
    
    
    //GET: -> CURRENT MONTHYEAR FOR FIREBASE DB
    static func getSpotMonthYearForDB(date:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter.string(from: date)
    }
    
    //GET: -> CURRENT DATE STRING /SCHEME
    static func getCurrentDateStringFromFormat(toFormat: String) -> String {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = toFormat
        
        return formatter.string(from: date)
    }
    
    //GET: -> CURRENT DAY STRING
    static func getCurrentStringDay() -> String {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = format_FULLDAY
        
        return formatter.string(from: date)
    }
    
    //GET: -> CURRENT DATE OBJECT
    static func getCurrentDateObject()-> Date {
        return Date()
    }
    
    //GET: -> CURRENT DATE STRING
    static func getCurrentDateString() -> String {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = format_YEAR_MONTH_DAY
        
        return formatter.string(from: date)
    }
    
    //GET: -> CURRENT DATE OBJECT
    public static func getCurrentDateObjectFromFormat(toFormat: String) -> Date {
        
        let formatter = DateFormatter()
        formatter.dateFormat = toFormat
        return formatter.date(from: getCurrentDateString())!
    }

    //CONVERT: -> STRING TO DATE OBJECT /SCHEME
   public static func convertStringToDateObjectForCalendar(dateStr: String) -> Date? {
       
       let dateByCTZ = self.convertStringFormat(date: dateStr,
                                       fromFormat: DateFormats.defaultFormatTimeUTC_original,
                                       toFormat: DateFormats.defaultFormatTimeUTC_original)
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = DateFormats.defaultFormatTimeUTC_original
       dateFormatter.calendar = NSCalendar.current
       return dateFormatter.date(from: dateByCTZ)
   }
    
    public static func convertStringToDateObjectForFirebaseDB(dateStr: String) -> Date? {
        
        let dateByCTZ = self.convertStringFormat(date: dateStr,
                                        fromFormat: DateFormats.defaultFormatTimeUTC,
                                        toFormat: DateFormats.defaultFormatTimeUTC)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormats.defaultFormatTimeUTC
        dateFormatter.calendar = NSCalendar.current
        return dateFormatter.date(from: dateByCTZ)
    }
    
    //CONVERT: -> STRING TO DATE OBJECT /SCHEME
    public static func convertStringToDateObjectByScheme(dateStr: String, fromFormat: String, toFormat: String) -> Date? {
        
        let dateByCTZ = self.convertStringFormat(date: dateStr,
                                        fromFormat: fromFormat,
                                        toFormat: toFormat)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = toFormat
        dateFormatter.calendar = NSCalendar.current
        return dateFormatter.date(from: dateByCTZ)
    }
    
    //CONVERT: -> STRING TO STRING /SCHEME
    static func convertStringDateToScheme(dateStr: String, toFormat: String) -> String {
        
        guard let date = convertStringToDateObjectByScheme(dateStr: dateStr, fromFormat: format_YEAR_MONTH_DAY, toFormat: toFormat)
            else { return "nil" }
        let formatter = DateFormatter()
        formatter.dateFormat = toFormat
        formatter.calendar = NSCalendar.current
        return formatter.string(from: date)
    }
    
    //CONVERT: -> STRING TO STRING /SCHEME
    public static func finderStringToDate(dateStr: String) -> Date? {
          
          let dateByCTZ = self.convertStringFormat(date: dateStr,
                                          fromFormat: format_YEAR_MONTH_DAY,
                                          toFormat: format_YEAR_MONTH_DAY)
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = format_YEAR_MONTH_DAY
          dateFormatter.calendar = NSCalendar.current
          return dateFormatter.date(from: dateByCTZ)
      }
//    static func finderStringToDate(dateStr: String) -> String {
//
//        guard let date = convertStringToDateObjectByScheme(dateStr: dateStr, fromFormat: format_YEAR_MONTH_DAY, toFormat: format_YEAR_MONTH_DAY)
//            else { return "nil" }
//        let formatter = DateFormatter()
//        formatter.dateFormat = format_YEAR_MONTH_DAY
//        formatter.calendar = NSCalendar.current
//        return formatter.string(from: date)
//    }
    
    //CONVERT: -> DATE TO STRING
    static func convertDateToString(dateObject: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format_YEAR_MONTH_DAY
        return formatter.string(from: dateObject)
    }
    
    //CONVERT: -> DATE TO STRING /SCHEME
    static func convertDateToStringForScheme(dateObject: Date, toFormat: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = toFormat
        return formatter.string(from: dateObject)
    }
    
    //ORIGINAL METHODS//
    static func getPreparedDateDT(dateUTC: String) -> String{
        let dateRangeStart = Date()
        if let dateEnd = self.convertToDate(dateUTC: dateUTC) {
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dateRangeStart, to: dateEnd)
            if isLessThan60seconds(components: components){
                return "Just Now"
            }else if isLessThan24(components: components) {
                return self.UTCToLocal(date: dateUTC, fromFormat: defaultFormatUTC, toFormat: defaultFormatTime)
            }
        }
        return self.UTCToLocal(date: dateUTC, fromFormat: defaultFormatUTC, toFormat: defaultFormatDate)
    }
    
    static func convertToDate(dateUTC: String) -> Date?{
        //convert date to current timezone
        let dateByCTZ = self.UTCToLocal(date: dateUTC,
                                        fromFormat: self.defaultFormatUTC,
                                        toFormat: self.defaultFormatUTC)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.defaultFormatUTC
        dateFormatter.calendar = NSCalendar.current
        return dateFormatter.date(from: dateByCTZ)
    }
    
    static func getCurrentUTC(format: String) -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    static func localToUTC(date:String, fromFormat: String, toFormat: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current
//        dateFormatter.date
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = toFormat
        
        return dateFormatter.string(from: dt!)
    }
    
    static func UTCToLocal(date:String, fromFormat: String, toFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        //dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = toFormat
        
        return dateFormatter.string(from: dt!)
    }
    
    static func convertStringFormat(date:String, fromFormat: String, toFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.dateFormat = toFormat
        
        guard let d = dt else { return "" }
        
        return dateFormatter.string(from: d)
    }
    
    static func getMonth(monthInt:Int) -> String {
        
        if monthInt == 1 { return "January" }
        if monthInt == 2 { return "February" }
        if monthInt == 3 { return "March" }
        if monthInt == 4 { return "April" }
        if monthInt == 5 { return "May" }
        if monthInt == 6 { return "June" }
        if monthInt == 7 { return "July" }
        if monthInt == 8 { return "August" }
        if monthInt == 9 { return "September" }
        if monthInt == 10 { return "October" }
        if monthInt == 11 { return "November" }
        if monthInt == 12 { return "December" }
        
        return "Unknown Month"
        
    }
    
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    func addOneDay() -> Date? {
        var dayComponent = DateComponents()
        dayComponent.day = 1 // For removing one day (yesterday): -1
        let theCalendar  = Calendar.current
        guard let nextDate = theCalendar.date(byAdding: dayComponent, to: self) else { return nil }
        return nextDate
    }
    
    func addOneMonth() -> Date? {
        var monthComponent = DateComponents()
        monthComponent.month = 1 // For removing one month: -1
        let theCalendar  = Calendar.current
        guard let nextMonth = theCalendar.date(byAdding: monthComponent, to: self) else { return nil }
        return nextMonth
    }
}
