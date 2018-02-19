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
import FacebookCore
import FacebookLogin

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
  
  lazy var signInWithFacebookButton: UIButton = {
    var button = UIButton(type: .system)
    button.setTitle("Login with Facebook", for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Service.buttonTitleFontSize)
    button.setTitleColor(Service.buttonTitleColor, for: .normal)
    button.backgroundColor = Service.buttonBackgroundColorSignInWithFacebook
    button.layer.masksToBounds = true
    button.layer.cornerRadius = Service.buttonCornerRadius
    
    button.setImage(#imageLiteral(resourceName: "FacebookButton").withRenderingMode(.alwaysTemplate), for: .normal)
    button.tintColor = .white
    button.contentMode = .scaleAspectFit
    
    button.addTarget(self, action: #selector(handleSignInWithFacebookButtonTapped), for: .touchUpInside)
    return button
  }()
  
  @objc func handleSignInWithFacebookButtonTapped() {
    hud.textLabel.text = "Logging in with Facebook..."
    hud.show(in: view, animated: true)
    let loginManager = LoginManager()
    loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { (result) in
      switch result {
      case .success(grantedPermissions: _, declinedPermissions: _, token: _):
        print("Succesfully logged in into Facebook.")
        self.signIntoFirebase()
      case .failed(let err):
        Service.dismissHud(self.hud, text: "Error", detailText: "Failed to get Facebook user with error: \(err)", delay: 3)
      case .cancelled:
        Service.dismissHud(self.hud, text: "Error", detailText: "Canceled getting Facebook user.", delay: 3)
      }
    }
  }
  
  fileprivate func signIntoFirebase() {
    guard let authenticationToken = AccessToken.current?.authenticationToken else { return }
    let credential = FacebookAuthProvider.credential(withAccessToken: authenticationToken)
    Auth.auth().signIn(with: credential) { (user, err) in
      if let err = err {
        Service.dismissHud(self.hud, text: "Sign up error", detailText: err.localizedDescription, delay: 3)
        return
      }
      print("Succesfully authenticated with Firebase.")
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
    view.addSubview(signInWithFacebookButton)
    
    signInAnonymouslyButton.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 50)
    
    signInWithFacebookButton.anchor(signInAnonymouslyButton.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 50)
  }
}

























