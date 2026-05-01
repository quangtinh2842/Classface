//
//  ProfileViewObserver.swift
//  Classface
//
//  Created by Soren Inis Ngo on 16/03/2026.
//

import Foundation

class ProfileViewObserver: NSObject, ObservableObject {
  @Published var uid: String = ""
  @Published var photoURL: String = ""
  @Published var fullName: String = ""
  @Published var email: String = ""
  
  init(user: CFUser) {
    self.uid = user.uid!
    self.photoURL = user.photoURL?.absoluteString ?? ""
    self.fullName = user.displayName!
    self.email = user.email!
  }
}
