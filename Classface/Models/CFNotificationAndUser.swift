//
//  CFNotificationAndUser.swift
//  Classface
//
//  Created by Soren Inis Ngo on 18/03/2026.
//

import Foundation

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
}
