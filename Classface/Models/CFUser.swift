//
//  CFUser.swift
//  Classface
//
//  Created by Soren Inis Ngo on 14/03/2026.
//

import Foundation
import FirebaseAuth
import GoogleSignIn

struct CFUser: CFBase {
  static let mockUser: CFUser = {
    var cfUser = CFUser()
    cfUser.uid = "007"
    cfUser.providerID = ""
    cfUser.displayName = "Tom"
    cfUser.email = "tom@gmail.com"
    cfUser.photoURL = URL(string: "https://upload.wikimedia.org/wikipedia/commons/9/9f/Cat_public_domain_dedication_image_0012.jpg")
    return cfUser
  }()
  
  static var currentUserFromDb: CFUser!
  
  static var currentUserFromAuth: CFUser? {
    if let currentUser = Auth.auth().currentUser {
      var cfUser = CFUser()
      cfUser.uid = currentUser.uid
      cfUser.displayName = currentUser.displayName
      cfUser.email = currentUser.email
      cfUser.photoURL = currentUser.photoURL
      
      if let provider = currentUser.providerData.first {
        cfUser.providerID = provider.providerID
      }
      
      return cfUser
    } else if let currentUser = GIDSignIn.sharedInstance.currentUser {
      var cfUser = CFUser()
      
      cfUser.uid = currentUser.userID
      cfUser.displayName = currentUser.profile?.name
      cfUser.email = currentUser.profile?.email
      cfUser.photoURL = currentUser.profile?.imageURL(withDimension: 200)
      cfUser.providerID = "google"
      
      return cfUser
    } else {
      return nil
    }
  }
  
  var uid: String?
  var providerID: String?
  var displayName: String?
  var email: String?
  var photoURL: URL?
  
  static func collectionName() -> String {
    return "synced_users"
  }
  
  static func primaryKey() -> String {
    return "uid"
  }
  
  var primaryKeyValue: String? {
    return uid
  }
  
  static func mapObject(jsonObject: NSDictionary) -> CFBase? {
    do {
      let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
      
      let decoder = JSONDecoder()
      
      let user = try decoder.decode(CFUser.self, from: data)
      
      return user
    } catch {
      return nil
    }
  }
  
  static func syncFromCurrentUser(completion handler: @escaping (Error?) -> Void) {
    guard let syncedUser = self.currentUserFromAuth else { return }
    
    do {
      try _ = syncedUser.save { error, ref in
        if let error = error {
          print("Error while syncing: \(error.localizedDescription)")
          handler(error)
        } else {
          print("Synced user into collection: \(CFUser.collectionName())")
          handler(nil)
        }
      }
    } catch {
      print("Error with Validation or storing: \(error.localizedDescription)")
      handler(error)
    }
  }
  
  static func signOutEverywhere(completion handler: ((Error?) -> ())? = nil) {
    do {
      try Auth.auth().signOut()
      GIDSignIn.sharedInstance.signOut()
      
      if handler != nil { handler!(nil) }
    } catch (let error as NSError) {
      if handler != nil { handler!(error) }
    }
  }
  
  func validate() -> (ModelValidationError, String?) {
    if self.uid == nil || self.uid!.isEmpty ||
        self.providerID == nil || self.providerID!.isEmpty {
      return (.InvalidId, "uid, providerID")
    }
    
    if self.displayName == nil || self.displayName!.isEmpty {
      return (.InvalidBlankAttribute, "displayName")
    }
    
    return (.Valid, nil)
  }
}
