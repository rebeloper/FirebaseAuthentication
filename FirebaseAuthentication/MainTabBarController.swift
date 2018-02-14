//
//  MainTabBarController.swift
//  FirebaseAuthentication
//
//  Created by Alex Nagy on 14/02/2018.
//  Copyright © 2018 Alex Nagy. All rights reserved.
//

import UIKit
import FirebaseAuth

class MainTabBarController: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .purple
    checkLoggedInUserStatus()
    setupViewControllers()
  }
  
  fileprivate func checkLoggedInUserStatus() {
    if Auth.auth().currentUser == nil {
      DispatchQueue.main.async {
        let signUpController = SignUpController()
        let signUpNavigationController = UINavigationController(rootViewController: signUpController)
        self.present(signUpNavigationController, animated: false, completion: nil)
        return
      }
    }
  }
  
  fileprivate func setupViewControllers() {
    tabBar.unselectedItemTintColor = Service.unselectedItemColor
    tabBar.tintColor = Service.darkBaseColor
    
    let homeController = HomeController()
    let homeNavigationController = UINavigationController(rootViewController: homeController)
    homeNavigationController.tabBarItem.image = #imageLiteral(resourceName: "MainTabBarItemHome").withRenderingMode(.alwaysTemplate)
    homeNavigationController.tabBarItem.selectedImage = #imageLiteral(resourceName: "MainTabBarItemHome").withRenderingMode(.alwaysTemplate)
    
    let userProfileController = UserProfileController()
    let userProfileNavigationController = UINavigationController(rootViewController: userProfileController)
    userProfileNavigationController.tabBarItem.image = #imageLiteral(resourceName: "MainTabBarItemProfile").withRenderingMode(.alwaysTemplate)
    userProfileNavigationController.tabBarItem.selectedImage = #imageLiteral(resourceName: "MainTabBarItemProfile").withRenderingMode(.alwaysTemplate)
    
    viewControllers = [homeNavigationController, userProfileNavigationController]
    
    guard let items = tabBar.items else { return }
    for item in items {
      item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
    }
  }
}














