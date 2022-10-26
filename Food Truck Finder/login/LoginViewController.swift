//
//  self.title = ""     self.view.backgroundColor = UIColor.swift
//  Food Truck Finder
//
//  Created by Charles Romeo on 3/10/20.
//  Copyright © 2020 Adrenaline Life. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import FirebaseCoreDiagnostics
import FileProvider

class LoginViewController: FUIAuthPickerViewController {

    override init(nibName: String?, bundle: Bundle?, authUI: FUIAuth) {
        super.init(nibName: "FUIAuthPickerViewController", bundle: bundle, authUI: authUI)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.title = "Login Please"
        self.view.backgroundColor = UIColor.red

    }
}
