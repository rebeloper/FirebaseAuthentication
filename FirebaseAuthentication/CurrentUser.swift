//
//  CurrentUser.swift
//  FirebaseAuthentication
//
//  Created by Alex Nagy on 20/02/2018.
//  Copyright © 2018 Alex Nagy. All rights reserved.
//

import Foundation

struct CurrentUser {
  let uid: String
  let name: String
  let email: String
  let profileImageUrl: String
  
  init(uid: String, dictionary: [String: Any]) {
    self.uid = uid
    self.name = dictionary["name"] as? String ?? ""
    self.email = dictionary["email"] as? String ?? ""
    self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
  }
}
