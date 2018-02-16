//
//  WelcomeController.swift
//  FirebaseAuthentication
//
//  Created by Alex Nagy on 14/02/2018.
//  Copyright © 2018 Alex Nagy. All rights reserved.
//

import UIKit
import LBTAComponents
import FirebaseAuth
import JGProgressHUD

class WelcomeController: UIViewController {
  
  let hud: JGProgressHUD = {
    let hud = JGProgressHUD(style: .light)
    hud.interactionType = .blockAllTouches
    return hud
  }()
  
  lazy var signInAnonymouslyButton: UIButton = {
    var button = UIButton(type: .system)
    button.setTitle("Sign In Anonymously", for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Service.buttonTitleFontSize)
    button.setTitleColor(Service.buttonTitleColor, for: .normal)
    button.backgroundColor = Service.buttonBackgroundColorSignInAnonymously
    button.layer.masksToBounds = true
    button.layer.cornerRadius = Service.buttonCornerRadius
    button.addTarget(self, action: #selector(handleSignInAnonymouslyButtonTapped), for: .touchUpInside)
    return button
  }()
  
  @objc func handleSignInAnonymouslyButtonTapped() {
    hud.textLabel.text = "Signing In Anonymously..."
    hud.show(in: view, animated: true)
    Auth.auth().signInAnonymously { (user, err) in
      if let err = err {
        self.hud.dismiss(animated: true)
        print("Failed to sign in anonymously with error", err)
        Service.showAlert(on: self, style: .alert, title: "Sign In Error", message: err.localizedDescription)
        return
      }
      print("Successfully signed in anonymously with uid:", user?.uid)
      self.hud.dismiss(animated: true)
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    navigationItem.title = "Welcome"
    setupViews()
  }
  
  fileprivate func setupViews() {
    view.addSubview(signInAnonymouslyButton)
    signInAnonymouslyButton.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 50)
  }
}
