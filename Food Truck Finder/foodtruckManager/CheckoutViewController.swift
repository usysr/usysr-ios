//
//  CheckoutViewController.swift
//  Food Truck Finder
//
//  Created by Charles Romeo on 3/12/20.
//  Copyright © 2020 Food Truck Finder Bham. All rights reserved.
//

import UIKit
import Stripe
import Firebase
import RealmSwift

/**
 * This example collects card payments, implementing the guide here: https://stripe.com/docs/payments/accept-a-payment#ios
 * To run this app, follow the steps here https://github.com/stripe-samples/accept-a-card-payment#how-to-run-locally
 */

class CheckoutViewController: UIViewController {
    var paymentIntentClientSecret: String?

    var user = User()
    var checkoutVC:FoodCartViewController?
    var ref : DatabaseReference!
    var listOfSpotsToBuy = List<Spot>()
    var amount = ""
    var clientSecret = ""
    var publishableKey = ""
    var loading = UIAlertController()
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var lblCheckoutHeader: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var imgCheckout: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSpotCount: UILabel!
    @IBOutlet weak var lblTotalCost: UILabel!
    
    let jsonObject: [String:Any] = [
        "amount":"1099",
        "currency":"usd",
        "metadata": [
            "description": "iOS Testing"
        ]
    ]
    
    lazy var cardTextField: STPPaymentCardTextField = {
        let cardTextField = STPPaymentCardTextField()
        cardTextField.textColor = UIColor.white
        return cardTextField
    }()
    lazy var payButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        button.setTitle("Pay", for: .normal)
        button.addTarget(self, action: #selector(pay), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.loading = Utils().showLoadingAlert()
        
        let stackView = UIStackView(arrangedSubviews: [cardTextField, payButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalToSystemSpacingAfter: view.leftAnchor, multiplier: 2),
            view.rightAnchor.constraint(equalToSystemSpacingAfter: stackView.rightAnchor, multiplier: 2),
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 40),
        ])
        setupDisplay()
        startCheckout()
    }
    
    func setupDisplay() {
        self.payButton.isEnabled = true
        cardView.fSpotDetailsPopUpDesign()
        imgCheckout.image = UIImage(named: "f_spot_two_dark.png")
        lblCheckoutHeader.setTitleAndImage(text: "Checkout", leftIcon: UIImage(named:"f_cart_light.png")?.resizeImage(scale: 0.25))
        lblName.text = self.user.name
        lblSpotCount.setTitleAndImage(text: String(self.listOfSpotsToBuy.count), leftIcon: UIImage(named:"f_spot_one_dark.png")?.resizeImage(scale: 0.25))
        lblTotalCost.setPriceWithImage(text: self.amount, leftIcon:UIImage(named:"f_calculator_dark.png")?.resizeImage(scale: 0.25), rightIcon: nil)
    }

    @IBAction func btnBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func displayAlert(title: String, message: String, isSuccess: Bool = false) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            if isSuccess {
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel) { _ in
                    self.checkoutVC?.doRefresh()
                    self.checkoutVC?.tabBarController?.selectedIndex = 0
                    self.dismiss(animated: true)
                })
            }
            else {
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            }
            self.present(alert, animated: true, completion: nil)
        }
    }

    func startCheckout() {
        // Create a PaymentIntent by calling the sample server's /create-payment-intent endpoint.
        
        let paymentIntentObject = PaymentIntent()
        paymentIntentObject.amount = self.amount.replacingOccurrences(of: ".", with: "")
        paymentIntentObject.descr = user.email
        let jObj = paymentIntentObject.buildJsonObject()
        
        let url = URL(string: FireHelper.paymentIntentUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: jObj)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data,
                let json = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??),
                let body = json!["body"] as? String else {
                    return
            }
            let d = body.data(using: .utf8)!
            do {
                if let keys = try JSONSerialization.jsonObject(with: d, options : .allowFragments) as? Dictionary<String,Any>
                {
                    self?.clientSecret = keys["clientSecret"] as! String
                    guard let pubKey = keys["publishableKey"] as? String else {
                        let message = error?.localizedDescription ?? "Failed to decode response from server."
                        self?.displayAlert(title: "Error loading page", message: message)
                        return
                    }
                    self?.publishableKey = pubKey
                } else {
                    print("bad json")
                }
            } catch let error as NSError {
                print(error)
            }
            print("Created PaymentIntent")
            guard let k = self?.publishableKey else { return }
            Stripe.setDefaultPublishableKey(k)
        })
        task.resume()
    }

    @objc
    func pay() {
        
        guard case self.paymentIntentClientSecret = paymentIntentClientSecret else { return; }
        self.payButton.isEnabled = false
        //Loading Alert
        self.present(self.loading, animated: true, completion: nil)
        // Collect card details
        let cardParams = cardTextField.cardParams
        let paymentMethodParams = STPPaymentMethodParams(card: cardParams, billingDetails: nil, metadata: nil)
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: self.clientSecret)
        paymentIntentParams.paymentMethodParams = paymentMethodParams
        
        // Submit the payment
        let paymentHandler = STPPaymentHandler.shared()
        paymentHandler.confirmPayment(withParams: paymentIntentParams, authenticationContext: self) { (status, paymentIntent, error) in
            switch (status) {
            case .failed:
                self.payButton.isEnabled = true
                self.loading.dismiss(animated: true, completion: nil)
                self.displayAlert(title: "Payment failed", message: error?.localizedDescription ?? "")
                break
            case .canceled:
                self.payButton.isEnabled = true
                self.loading.dismiss(animated: true, completion: nil)
                self.displayAlert(title: "Payment canceled", message: error?.localizedDescription ?? "")
                break
            case .succeeded:
                self.runQueueToPurchaseSpots()
                self.loading.dismiss(animated: true, completion: nil)
                self.displayAlert(title: "Payment succeeded", message: "Thanks for booking!", isSuccess: true)
                break
            @unknown default:
                self.payButton.isEnabled = true
                self.loading.dismiss(animated: true, completion: nil)
                fatalError()
                break
            }
        }
        self.loading.dismiss(animated: true, completion: nil)
    }
    
    func runQueueToPurchaseSpots() {
        for s in self.listOfSpotsToBuy {
            updateSpotAsSold(spot: s)
        }
    }
    
    //TODO: CONVERT THIS FOLLOWING METHOD TO MATCH THE DATE!
    
    //-> Update ALL SPOTS to "booked"
    func updateSpotAsSold( spot : Spot ) {
        
        guard let date = spot.date else { return }
        guard let d = DateUtils.convertToDate(dateUTC: date) else { return }
        let m = FireHelper.getSpotMonthYearForDBbyDate(date: d)
        
        guard let updatedSpot = Session.updateSpotForFirebase(spot: spot, status: FireHelper.BOOKED) else {
            return
        }
        
        guard let id = updatedSpot.id else { return }
        
        ref = FireHelper.getSpotsForMonth(month: m).child(id)
        ref.setValue(updatedSpot.convertToDictionary()) { (error:Error?, ref:DatabaseReference) in
            //Error Handling
            if let error = error {
                Utils().showServerUnavailableAlert(context: self)
                print("Failed to set spot to pending, \(error)")
            } else {
                //Successfully saved
                //->Remove Spot From Cart
                Session.removeSpotFromCart(spot: spot)
                print("Spot sold in Firebase")
            }
        }
    }
}

extension CheckoutViewController: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}



