//
//  Extentions.swift
//  Food Truck Finder
//
//  Created by Charles Romeo on 5/6/20.
//  Copyright © 2020 Food Truck Finder Bham. All rights reserved.
//

import Foundation
import UIKit

class Extentions {}

extension UIColor {
    //Logo Colors
    static let fLightBlue = UIColor(red: 190/255, green: 210/255, blue: 255/255, alpha: 1.0) //hex:
    static let fDarkBlue = UIColor(red: 54/255, green: 75/255, blue: 105/255, alpha: 1.0) //hex: 364b69
    static let fOrangeOne = UIColor(red: 249/255, green: 180/255, blue: 139/255, alpha: 1.0)
}

extension UIImage {
    //All Icons
    static let f_add_Light = "f_add_light.png"
    static let f_add_Dark = "f_add_dark.png"
    static let f_calculator_Light = "f_calculator_light.png"
    static let f_calculator_Dark = "f_calculator_dark.png"
    static let f_calendar_Light = "f_calendar_light.png"
    static let f_calendar_Dark = "f_calendar_dark.png"
    static let f_check_Light = "f_check_light.png"
    static let f_check_Dark = "f_check_dark.png"
    static let f_cart_Light = "f_cart_light.png"
    static let f_cart_Dark = "f_cart_dark.png"
    static let f_dashboard_Light = "f_dashboard_light.png"
    static let f_dashboard_Dark = "f_dashboard_dark.png"
    static let f_food_Light = "f_food_light.png"
    static let f_food_Dark = "f_food_dark.png"
    static let f_minus_Light = "f_minus_light.png"
    static let f_minus_Dark = "f_minus_dark.png"
    static let f_people_Light = "f_people_light.png"
    static let f_people_Dark = "f_people_dark.png"
    static let f_profile_Light = "f_profile_light.png"
    static let f_profile_Dark = "f_profile_dark.png"
    static let f_power_Light = "f_power_light.png"
    static let f_power_Dark = "f_power_dark.png"
    static let f_spot_one_Light = "f_spot_one_light.png"
    static let f_spot_one_Dark = "f_spot_one_dark.png"
    static let f_spot_two_Light = "f_spot_two_light.png"
    static let f_spot_two_Dark = "f_spot_two_dark.png"
    static let f_truck_Light = "f_truck_light.png"
    static let f_truck_Dark = "f_truck_dark.png"
  
    func resizeImage(scale: CGFloat) -> UIImage {
        let newSize = CGSize(width: self.size.width*scale, height: self.size.height*scale)
        let rect = CGRect(origin: CGPoint.zero, size: newSize)
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!

        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!

        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)

        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    
}

extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}

extension UICollectionView {

    func deselectAllItems(animated: Bool) {
        guard let selectedItems = indexPathsForSelectedItems else { return }
        for indexPath in selectedItems { deselectItem(at: indexPath, animated: animated) }
    }
}

extension UIButton{
    
    //Button Design
    
    func fCircleDesign() {
        
        self.frame = CGRect(x: 160, y: 100, width: 50, height: 50)
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        self.clipsToBounds = true
        self.setImage(UIImage(named:"f_add_light.png")!, for: .normal)
        self.tintColor = UIColor.fLightBlue
        self.setTitleColor(UIColor.white, for: .normal)
        self.backgroundColor = UIColor.fDarkBlue
        
    }
    func fDesignImageLeftTitleRight(title: String, image: String){
        self.frame = CGRect(x: 100, y: 100, width: 75, height: 35)
        self.setImage(UIImage(named: image), for: UIControl.State.normal)
        self.imageView?.contentMode = .scaleAspectFit
        self.moveImageTextLeft()
        self.backgroundColor = UIColor.fLightBlue
        self.setTitle(title, for: .normal)
        self.setTitleColor(UIColor.black, for: .normal)
        self.tintColor = UIColor.fDarkBlue
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
    }
    func fDesign(title: String){
        self.frame = CGRect(x: 100, y: 100, width: 75, height: 35)
        self.backgroundColor = UIColor.fLightBlue
        self.setTitle(title, for: .normal)
        self.setTitleColor(UIColor.black, for: .normal)
        self.tintColor = UIColor.fDarkBlue
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    func fDesignCartCheckout(){
        self.setImage(UIImage(named: "f_cart_light.png"), for: UIControl.State.normal)
        self.imageView?.contentMode = .scaleAspectFit
        self.moveImageTextCenter()
        self.backgroundColor = UIColor.fLightBlue
        self.setTitleColor(UIColor.black, for: .normal)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    func moveImageTextLeft(imagePadding: CGFloat = 20.0, titlePadding: CGFloat = 0.0, minImageTitleDistance: CGFloat = 10.0){
        guard let imageViewWidth = imageView?.frame.width else{return}
        guard let titleLabelWidth = titleLabel?.intrinsicContentSize.width else{return}
        contentHorizontalAlignment = .left
        let imageLeftInset = imagePadding - imageViewWidth / 2
        var titleLeftInset = (bounds.width - titleLabelWidth) / 2 - imageViewWidth + titlePadding
        if titleLeftInset - imageLeftInset < minImageTitleDistance{
            titleLeftInset = imageLeftInset + minImageTitleDistance
        }
        imageEdgeInsets = UIEdgeInsets(top: 0.0, left: (imageLeftInset), bottom: 0.0, right: 0.0)
        titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -60.0, bottom: 0.0, right: 0.0)
    }
    
    func moveImageTextCenter(imagePadding: CGFloat = 0.0, titlePadding: CGFloat = 0.0, minImageTitleDistance: CGFloat = 0.0){
        guard let imageViewWidth = imageView?.frame.width else{return}
        guard let titleLabelWidth = titleLabel?.intrinsicContentSize.width else{return}
        contentHorizontalAlignment = .left
        let imageLeftInset = imagePadding - imageViewWidth / 2
        var titleLeftInset = (bounds.width - titleLabelWidth) / 2 - imageViewWidth + titlePadding
        if titleLeftInset - imageLeftInset < minImageTitleDistance{
            titleLeftInset = imageLeftInset + minImageTitleDistance
        }
        imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
}

extension UILabel {
    
    func setTitleAndImage(text:String, leftIcon: UIImage? = nil, rightIcon: UIImage? = nil) {
        let leftAttachment = NSTextAttachment()
        leftAttachment.image = leftIcon
        leftAttachment.bounds = CGRect(x: 0, y: -6, width: 100, height: 20)
        if let leftIcon = leftIcon {
            leftAttachment.bounds = CGRect(x: 0, y: -6, width: leftIcon.size.width, height: leftIcon.size.height)
        }
        let leftAttachmentStr = NSAttributedString(attachment: leftAttachment)
        let myString = NSMutableAttributedString(string: "")
        let theText = NSAttributedString(string: text)
        if semanticContentAttribute == .forceRightToLeft {
            myString.append(theText)
            myString.append(leftAttachmentStr)
        } else {
            myString.append(leftAttachmentStr)
            myString.append(theText)
        }
        attributedText = myString
    }
    
    func setPriceWithImage(text:String, leftIcon: UIImage? = nil, rightIcon: UIImage? = nil) {
        let secondLast = text.substring(fromIndex: text.length - 2)
        var nText = ""
        if secondLast == "00" {
            nText = "$\(text)"
        } else {
            nText = "$\(text)0"
        }
        let leftAttachment = NSTextAttachment()
        leftAttachment.image = leftIcon
        leftAttachment.bounds = CGRect(x: 0, y: -6, width: 100, height: 20)
        if let leftIcon = leftIcon {
            leftAttachment.bounds = CGRect(x: 0, y: -6, width: leftIcon.size.width, height: leftIcon.size.height)
        }
        let leftAttachmentStr = NSAttributedString(attachment: leftAttachment)

        let myString = NSMutableAttributedString(string: "")
        let theText = NSAttributedString(string: nText)

        if semanticContentAttribute == .forceRightToLeft {
            myString.append(theText)
            myString.append(leftAttachmentStr)
        } else {
            myString.append(leftAttachmentStr)
            myString.append(theText)
        }
        attributedText = myString
    }
    
    func fCityStateZip(city:String,state:String,zip:String) {
        self.text = "\(city), \(state) \(zip)"
    }
    
    func fContact(contact:String) {
        self.text = "Contact: \(contact)"
    }
    
    func fMealType(mealType:String) {
        self.text = "\(mealType)"
    }
    
    func fMealTime(mealTime:String) {
        self.text = "\(mealTime)"
    }
    
    func fEstPeople(estPeople:String) {
        self.text = "People: \(estPeople)"
    }
    
    func fDate(date:String, mealTime:String) {
        let d = DateUtils.convertStringDateToScheme(dateStr: date, toFormat: DateUtils.format_FULLDAY_MONTH_DAY_YEAR)
        self.text = "\(mealTime), \(d)"
    }
    
    func fDate(date:String) {
        self.text = DateUtils.convertStringDateToScheme(dateStr: date, toFormat: DateUtils.format_FULLDAY_MONTH_DAY_YEAR)
    }
    
    func fPrice(price:String) {
        let secondLast = price.substring(fromIndex: price.length - 2)
        if secondLast == "00" {
            self.text = "$\(price)"
        } else {
            self.text = "$\(price)0"
        }
    }
    
    func fTotalCost(totalCost:String) {
        self.text = "$\(totalCost)"
    }
}

extension UIView {
    
    func fMapView() {
        
        self.layer.cornerRadius = 8
    }
    
    func fSpotDetailsPopUpDesign() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.fDarkBlue.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: -1, height: 3)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 2
        self.layer.cornerRadius = 8
    }
    
    func fMainTableCellBackgroundDesign() {
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
    
    func fMainTableCellShadowDesign() {
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: -1, height: 3)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 2
        self.layer.cornerRadius = 8
    }
    
    func fCartTableCellShadowDesign() {
           self.layer.masksToBounds = false
           self.layer.shadowOffset = CGSize(width: -1, height: 3)
           self.layer.shadowColor = UIColor.black.cgColor
           self.layer.shadowOpacity = 0.2
           self.layer.shadowRadius = 2
           self.layer.cornerRadius = 8
       }
       
    
    func fCalendarDesign() {
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: -1, height: 3)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
    }
    
}

extension UIView {

    enum Visibility {
        case visible
        case invisible
        case gone
    }

    var visibility: Visibility {
        get {
            let constraint = (self.constraints.filter{$0.firstAttribute == .height && $0.constant == 0}.first)
            if let constraint = constraint, constraint.isActive {
                return .gone
            } else {
                return self.isHidden ? .invisible : .visible
            }
        }
        set {
            if self.visibility != newValue {
                self.setVisibility(newValue)
            }
        }
    }

    private func setVisibility(_ visibility: Visibility) {
        let constraint = (self.constraints.filter{$0.firstAttribute == .height && $0.constant == 0}.first)

        switch visibility {
        case .visible:
            constraint?.isActive = false
            self.isHidden = false
            break
        case .invisible:
            constraint?.isActive = false
            self.isHidden = true
            break
        case .gone:
            if let constraint = constraint {
                constraint.isActive = true
            } else {
                let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
                self.addConstraint(constraint)
                constraint.isActive = true
            }
        }
    }
}

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

extension NSAttributedString {
    func attributedStringWithResizedImages(with maxWidth: CGFloat) -> NSAttributedString {
        let text = NSMutableAttributedString(attributedString: self)
        text.enumerateAttribute(NSAttributedString.Key.attachment, in: NSMakeRange(0, text.length), options: .init(rawValue: 0), using: { (value, range, stop) in
            if let attachement = value as? NSTextAttachment {
                let image = attachement.image(forBounds: attachement.bounds, textContainer: NSTextContainer(), characterIndex: range.location)!
                if image.size.width > maxWidth {
                    let newImage = image.resizeImage(scale: maxWidth/image.size.width)
                    let newAttribut = NSTextAttachment()
                    newAttribut.image = newImage
                    text.addAttribute(NSAttributedString.Key.attachment, value: newAttribut, range: range)
                }
            }
        })
        return text
    }
}
