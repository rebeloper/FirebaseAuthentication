//
//  Service.swift
//  FirebaseAuthentication
//
//  Created by Alex Nagy on 14/02/2018.
//  Copyright © 2018 Alex Nagy. All rights reserved.
//

import UIKit
import LBTAComponents
import JGProgressHUD

class Service {
  static let baseColor = UIColor(r: 254, g: 202, b: 64)
  static let darkBaseColor = UIColor(r: 253, g: 166, b: 47)
  static let unselectedItemColor = UIColor(r: 173, g: 173, b: 173)
  
  static let buttonTitleFontSize: CGFloat = 16
  static let buttonTitleColor = UIColor.white
  static let buttonBackgroundColorSignInAnonymously = UIColor(r: 54, g: 54, b: 54)
  static let buttonBackgroundColorSignInWithFacebook = UIColor(r: 88, g: 86, b: 214)
  static let buttonBackgroundColorSignInWithTwitter = UIColor(r: 90, g: 200, b: 250)
  static let buttonCornerRadius: CGFloat = 7
  
  static let twitterKey = "TU2fZu7jPxDaMPwm1sDrEBsdb"
  static let twitterSecret = "fizqSQz1B0HxSsSgqIduDCidbQfIp5LiXxrVVRL4SwMLGj7blS"
  
  static func showAlert(on: UIViewController, style: UIAlertControllerStyle, title: String?, message: String?, actions: [UIAlertAction] = [UIAlertAction(title: "Ok", style: .default, handler: nil)], completion: (() -> Swift.Void)? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: style)
    for action in actions {
      alert.addAction(action)
    }
    on.present(alert, animated: true, completion: completion)
  }
  
  static func dismissHud(_ hud: JGProgressHUD, text: String, detailText: String, delay: TimeInterval) {
    hud.textLabel.text = text
    hud.detailTextLabel.text = detailText
    hud.dismiss(afterDelay: delay, animated: true)
  }
}
