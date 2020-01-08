//
//  AppRoute.swift
//  Translate
//
//  Created by admin on 08/01/2020.
//  Copyright © 2020 SangNX. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class AppRouter {
    
    static let shared = AppRouter()
    
    func openHome() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let appWindow = appDelegate.window else { return }
        
        let topicVC = ListTopicVC()
        topicVC.tabBarItem = UITabBarItem(title: "Bài học", image: #imageLiteral(resourceName: "topic"), tag: 0)
        
        let listenVC = ListListenVC()
        listenVC.tabBarItem = UITabBarItem(title: "Luyện nghe", image: #imageLiteral(resourceName: "listen"), tag: 1)

        let speakVC = ListSpeakVC()
        speakVC.tabBarItem = UITabBarItem(title: "Luyện nói", image: #imageLiteral(resourceName: "speak"), tag: 2)
        
        let infoVC = InfoVC()
        infoVC.tabBarItem = UITabBarItem(title: "Thông tin", image: #imageLiteral(resourceName: "info"), tag: 3)
        
        let tabbar = UITabBarController()
        tabbar.viewControllers = [topicVC, listenVC, speakVC, infoVC]
        tabbar.selectedIndex = 0
        
        appWindow.rootViewController = tabbar
    }
    
    func openLogin() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let appWindow = appDelegate.window else { return }
        appWindow.rootViewController = LoginViewController()
    }
    
    func updateAppRouter() {
         if (Auth.auth().currentUser?.uid != nil) {
             AppRouter.shared.openHome()
         } else {
             AppRouter.shared.openLogin()
         }
    }
}