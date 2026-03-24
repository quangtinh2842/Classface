//
//  CFNotificationAndUser.swift
//  Classface
//
//  Created by Soren Inis Ngo on 18/03/2026.
//

import Foundation
import FirebaseDatabase

struct CFNotificationAndUser: CFBase {
  static var junctionRecordsOfCurrentUser: [CFNotificationAndUser]?
  
  //  "notification_1_id_user_1_id": {
  //    "notification_1_id": true,
  //    "user_1_id": true
  //    "id": "notification_1_id_user_1_id"
  //  }
  
  var id: String?
  var wasRead: Bool = false
  
  static func collectionName() -> String {
    return "notification_and_user_junction_records"
  }
  
  static func primaryKey() -> String {
    return "id"
  }
  
  var primaryKeyValue: String? {
    return id
  }
  
  static func mapObject(jsonObject: NSDictionary) -> CFBase? {
    do {
      let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
      let decoder = JSONDecoder()
      let junctionRecord = try decoder.decode(CFNotificationAndUser.self, from: data)
      return junctionRecord
    } catch {
      return nil
    }
  }
  
  func validate() -> (ModelValidationError, String?) {
    if self.id == nil || self.id!.isEmpty {
      return (.InvalidId, "id")
    }
    
    return (.Valid, nil)
  }
  
  func getNid() -> String {
    return self.id!.components(separatedBy: "_").first!
  }
  
  func save(completion handler: UpdateValueHandler?) throws -> String {
    var record = [String: AnyObject]()
    record[CFUser.currentUserFromAuth!.uid!] = true as AnyObject
    record[self.getNid()] = true as AnyObject
    record["id"] = self.id! as AnyObject
    record["wasRead"] = self.wasRead as AnyObject
    
    let updatesManifest = ["/\(CFNotificationAndUser.collectionName())/\(self.id!)": record]
    let dbRef = Database.database().reference()
    dbRef.updateChildValues(updatesManifest)
    
    if handler != nil {
      handler!(nil, dbRef)
    }
    
    return self.id!
  }
}
