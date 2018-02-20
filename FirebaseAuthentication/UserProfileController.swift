//
//  UserProfileController.swift
//  FirebaseAuthentication
//
//  Created by Alex Nagy on 14/02/2018.
//  Copyright © 2018 Alex Nagy. All rights reserved.
//

import UIKit
import FirebaseAuth
import LBTAComponents
import FirebaseDatabase
import FirebaseStorage
import JGProgressHUD

class UserProfileController: UIViewController {
  
  let hud: JGProgressHUD = {
    let hud = JGProgressHUD(style: .light)
    hud.interactionType = .blockAllTouches
    return hud
  }()
  
  let profileImageViewHeight: CGFloat = 56
  lazy var profileImageView: CachedImageView = {
    var iv = CachedImageView()
    iv.backgroundColor = Service.baseColor
    iv.contentMode = .scaleAspectFill
    iv.layer.cornerRadius = profileImageViewHeight / 2
    iv.clipsToBounds = true
    return iv
  }()
  
  let nameLabel: UILabel = {
    let label = UILabel()
    label.text = "User's Name"
    label.font = UIFont.boldSystemFont(ofSize: 18)
    return label
  }()
  
  let uidLabel: UILabel = {
    let label = UILabel()
    label.text = "User's Uid"
    label.font = UIFont.systemFont(ofSize: 14)
    label.textColor = .lightGray
    return label
  }()
  
  let emailLabel: UILabel = {
    let label = UILabel()
    label.text = "User's Email"
    label.font = UIFont.systemFont(ofSize: 14)
    label.textColor = .lightGray
    return label
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    navigationItem.title = "User Profile"
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .done, target: self, action: #selector(handleSignOutButtonTapped))
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Fetch User", style: .done, target: self, action: #selector(handleFetchUserButtonTapped))
    
    setupViews()
  }
  
  @objc func handleFetchUserButtonTapped() {
    hud.textLabel.text = "Fetching user..."
    hud.show(in: view, animated: true)
    if Auth.auth().currentUser != nil {
      guard let uid = Auth.auth().currentUser?.uid else { Service.dismissHud(self.hud, text: "Error", detailText: "Failed to fetch user.", delay: 3); return }
      Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
        guard let dictionary = snapshot.value as? [String : Any] else { Service.dismissHud(self.hud, text: "Error", detailText: "Failed to fetch user.", delay: 3); return }
        let user = CurrentUser(uid: uid, dictionary: dictionary)
        
        self.uidLabel.text = uid
        self.nameLabel.text = user.name
        self.emailLabel.text = user.email
        self.profileImageView.loadImage(urlString: user.profileImageUrl)
        
        Service.dismissHud(self.hud, text: "Success", detailText: "User fetched!", delay: 1)
        
      }, withCancel: { (err) in
        Service.dismissHud(self.hud, text: "Error", detailText: "Failed to fetch user with error: \(err)", delay: 3)
      })
    }
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
  
  fileprivate func setupViews() {
    view.addSubview(profileImageView)
    view.addSubview(nameLabel)
    view.addSubview(uidLabel)
    view.addSubview(emailLabel)
    
    profileImageView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: nil, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: profileImageViewHeight, heightConstant: profileImageViewHeight)
    nameLabel.anchor(view.safeAreaLayoutGuide.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 24, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 0)
    uidLabel.anchor(nameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 8, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 0)
    emailLabel.anchor(uidLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 6, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 0)
  }
  
  
}






















