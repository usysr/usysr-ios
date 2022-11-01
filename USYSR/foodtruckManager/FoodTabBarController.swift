//
//  FoodTabBarController.swift
//  Food Truck Finder
//
//  Created by Charles Romeo on 5/14/20.
//  Copyright © 2020 Food truck finder bham. All rights reserved.
//

import UIKit

class FoodTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func getDash() {
        self.selectedIndex = 0
    }
    
//    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        print("did select = \(item)")
//        print("did select = \(item)")
//    }
//
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        print("did select = \(String(describing: viewController.nibName))")
//    }

}
