////
////  InterSwitchPaymentUI.swift
////  mobpay-ios
////
////  Created by Allan Mageto on 20/06/2019.
////  Copyright © 2019 Allan Mageto. All rights reserved.
////
//
//import Eureka
//
//open class InterSwitchPaymentUI : UIViewController {
//    let tabBarCnt = UITabBarController()
//    
//    
//    override open func viewDidLoad() {
//        super.viewDidLoad()
//        tabBarCnt.tabBar.tintColor = UIColor.black
//        createTabBarController()
//    }
//    
//    func createTabBarController() {
//        
//        let cardViewController = CardPaymentUI()
//        cardViewController.title = "Card Payment"
//        cardViewController.view.backgroundColor =  UIColor.red
//        cardViewController.tabBarItem = UITabBarItem.init(title: "Home", image: UIImage(named: "HomeTab"), tag: 0)
//        
//        let mobileMoneyController = MobilePaymentUI()
//        mobileMoneyController.title = "Second"
//        mobileMoneyController.view.backgroundColor =  UIColor.green
//        mobileMoneyController.tabBarItem = UITabBarItem.init(title: "Location", image: UIImage(named: "Location"), tag: 1)
//        
//        let controllerArray = [cardViewController, mobileMoneyController]
//        tabBarCnt.viewControllers = controllerArray.map{ UINavigationController.init(rootViewController: $0)}
//        
//        self.view.addSubview(tabBarCnt.view)
//    }
//}
//
//
//
//
//
//
//
