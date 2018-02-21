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
import SwiftyJSON
import FirebaseStorage
import FirebaseDatabase
import TwitterKit

class WelcomeController: UIViewController {
  
  var twitterSession: TWTRSession?
  
  var name: String? = ""
  var username: String? = ""
  var email: String? = ""
  var profileImage: UIImage?
  
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
      self.fetchFacebookUser()
    }
  }
  
  fileprivate func fetchFacebookUser() {
    
    let graphRequestConnection = GraphRequestConnection()
    let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id, email, name, picture.type(large)"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: .defaultVersion)
    graphRequestConnection.add(graphRequest, completion: { (httpResponse, result) in
      switch result {
      case .success(response: let response):
        
        guard let responseDict = response.dictionaryValue else { Service.dismissHud(self.hud, text: "Error", detailText: "Failed to fetch user.", delay: 3); return }
        
        let json = JSON(responseDict)
        self.name = json["name"].string
        self.email = json["email"].string
        guard let profilePictureUrl = json["picture"]["data"]["url"].string else { Service.dismissHud(self.hud, text: "Error", detailText: "Failed to fetch user.", delay: 3); return }
        guard let url = URL(string: profilePictureUrl) else { Service.dismissHud(self.hud, text: "Error", detailText: "Failed to fetch user.", delay: 3); return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
          if err != nil {
            guard let err = err else { Service.dismissHud(self.hud, text: "Error", detailText: "Failed to fetch user.", delay: 3); return }
            Service.dismissHud(self.hud, text: "Fetch error", detailText: err.localizedDescription, delay: 3)
            return
          }
          guard let data = data else { Service.dismissHud(self.hud, text: "Error", detailText: "Failed to fetch user.", delay: 3); return }
          self.profileImage = UIImage(data: data)
          self.saveUserIntoFirebaseDatabase()
          
          }.resume()
        
        break
      case .failed(let err):
        Service.dismissHud(self.hud, text: "Error", detailText: "Failed to get Facebook user with error: \(err)", delay: 3)
        break
      }
    })
    graphRequestConnection.start()
    
    
  }
  
  fileprivate func saveUserIntoFirebaseDatabase() {
    
    guard let uid = Auth.auth().currentUser?.uid,
      let name = self.name,
      let username = self.username,
      let email = self.email,
      let profileImage = profileImage,
      let profileImageUploadData = UIImageJPEGRepresentation(profileImage, 0.3) else { Service.dismissHud(self.hud, text: "Error", detailText: "Failed to save user.", delay: 3); return }
    let fileName = UUID().uuidString
    
    Storage.storage().reference().child("profileImages").child(fileName).putData(profileImageUploadData, metadata: nil) { (metadata, err) in
      if let err = err {
        Service.dismissHud(self.hud, text: "Error", detailText: "Failed to save user with error: \(err)", delay: 3);
        return
      }
      guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else { Service.dismissHud(self.hud, text: "Error", detailText: "Failed to save user.", delay: 3); return }
      print("Successfully uploaded profile image into Firebase storage with URL:", profileImageUrl)
      
      let dictionaryValues = ["name": name,
                              "email": email,
                              "username": username,
                              "profileImageUrl": profileImageUrl]
      let values = [uid : dictionaryValues]
      
      Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
        if let err = err {
          Service.dismissHud(self.hud, text: "Error", detailText: "Failed to save user info with error: \(err)", delay: 3)
          return
        }
        print("Successfully saved user info into Firebase database")
        // after successfull save dismiss the welcome view controller
        self.hud.dismiss(animated: true)
        self.dismiss(animated: true, completion: nil)
      })
    }
    
    
    
  }
  
  let signInWithTwitterButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle(" Login with Twitter", for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Service.buttonTitleFontSize)
    button.setTitleColor(Service.buttonTitleColor, for: .normal)
    button.backgroundColor = Service.buttonBackgroundColorSignInWithTwitter
    button.layer.masksToBounds = true
    button.layer.cornerRadius = Service.buttonCornerRadius
    
    button.setImage(#imageLiteral(resourceName: "TwitterButton").withRenderingMode(.alwaysTemplate), for: .normal)
    button.tintColor = .white
    button.contentMode = .scaleAspectFit
    
    button.addTarget(self, action: #selector(handleTwitterButtonTapped), for: .touchUpInside)
    return button
  }()
  
  @objc func handleTwitterButtonTapped() {
    hud.textLabel.text = "Logging In with Twitter..."
    hud.show(in: view, animated: true)
    TWTRTwitter.sharedInstance().logIn { (session, err) in
      if let err = err {
        Service.dismissHud(self.hud, text: "Error", detailText: "Failed to log in with Twitter with error: \(err)", delay: 3)
        return
      }
      
      guard let session = session else { return }
      self.twitterSession = session
      self.signIntoFirebaseWithTwitter()
    }
  }
  
  func signIntoFirebaseWithTwitter() {
    guard let twitterSession = twitterSession else { return }
    let credential = TwitterAuthProvider.credential(withToken: twitterSession.authToken, secret: twitterSession.authTokenSecret)
    Auth.auth().signIn(with: credential) { (user, err) in
      if let err = err {
        print("Failed to create Firebase user:", err)
        Service.dismissHud(self.hud, text: "Sign up error", detailText: err.localizedDescription, delay: 3)
        return
      }
      print("Successfully created firebase user:", user?.uid ?? "" )
      self.fetchTwitterUser()
    }
  }
  
  func fetchTwitterUser() {
    guard let twitterSession = twitterSession else { return }
    let client = TWTRAPIClient()
    client.loadUser(withID: twitterSession.userID, completion: { (user, err) in
      if let err = err {
        Service.dismissHud(self.hud, text: "Twitter user error", detailText: err.localizedDescription, delay: 3)
        return
      }
      
      guard let user = user else { return }
      self.name = user.name
      self.username = twitterSession.userName
      let profilePictureUrl = user.profileImageLargeURL
      guard let url = URL(string: profilePictureUrl) else { Service.dismissHud(self.hud, text: "Error", detailText: "Failed to fetch user.", delay: 3); return }
      
      URLSession.shared.dataTask(with: url) { (data, response, err) in
        if err != nil {
          guard let err = err else { Service.dismissHud(self.hud, text: "Error", detailText: "Failed to fetch user.", delay: 3); return }
          Service.dismissHud(self.hud, text: "Fetch error", detailText: err.localizedDescription, delay: 3)
          return
        }
        guard let data = data else { Service.dismissHud(self.hud, text: "Error", detailText: "Failed to fetch user.", delay: 3); return }
        self.profileImage = UIImage(data: data)
        self.saveUserIntoFirebaseDatabase()
        
        }.resume()
      
    })
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
    view.addSubview(signInWithTwitterButton)
    
    signInAnonymouslyButton.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 50)
    
    signInWithFacebookButton.anchor(signInAnonymouslyButton.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 50)
    
    signInWithTwitterButton.anchor(signInWithFacebookButton.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 50)
  }
}

























