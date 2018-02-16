//
//  UserProfileController.swift
//  FirebaseAuthentication
//
//  Created by Alex Nagy on 14/02/2018.
//  Copyright © 2018 Alex Nagy. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserProfileController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    navigationItem.title = "User Profile"
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .done, target: self, action: #selector(handleSignOutButtonTapped))
  }
  
  @objc func handleSignOutButtonTapped() {
    let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { (action) in
      do {
        try Auth.auth().signOut()
        let welcomeController = WelcomeController()
        let welcomeNavigationController = UINavigationController(rootViewController: welcomeController)
        self.present(welcomeNavigationController, animated: true, completion: nil)
      } catch let err {
        print("Failed to sign out with error", err)
        Service.showAlert(on: self, style: .alert, title: "Sign Out Error", message: err.localizedDescription)
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    Service.showAlert(on: self, style: .actionSheet, title: nil, message: nil, actions: [signOutAction, cancelAction], completion: nil)
    
    
  }
}
