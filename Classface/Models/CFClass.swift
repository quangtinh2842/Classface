//
//  CFClass.swift
//  Classface
//
//  Created by Soren Inis Ngo on 14/03/2026.
//

import Foundation
import FirebaseDatabase

struct CFClass: CFBase {
  var cid: String?
  var className: String?
  var rollCallerId: String?
  var backgroundURL: String?
  var lecturerName: String?
  
  static func collectionName() -> String {
    return "classes"
  }
  
  static func primaryKey() -> String {
    return "cid"
  }
  
  var primaryKeyValue: String? {
    return cid
  }
  
  static func mapObject(jsonObject: NSDictionary) -> CFBase? {
    do {
      let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
      let decoder = JSONDecoder()
      let cfClass = try decoder.decode(CFClass.self, from: data)
      return cfClass
    } catch {
      return nil
    }
  }
  
  func validate() -> (ModelValidationError, String?) {
    if self.cid == nil || self.cid!.isEmpty ||
        self.rollCallerId == nil || self.rollCallerId!.isEmpty {
      return (.InvalidId, "cid, rollCallerId")
    }
    
    if self.className == nil || self.className!.isEmpty ||
        self.backgroundURL == nil || self.backgroundURL!.isEmpty ||
        self.lecturerName == nil || self.lecturerName!.isEmpty {
      return (.InvalidBlankAttribute, "className, backgroundURL, lecturerName")
    }
    
    return (.Valid, nil)
  }
  
  static func deleteWithId(_ id: String, completion handler: @escaping (Error?) -> Void) {
    let ref = Database.database().reference().child(CFClass.collectionName()).child(id)
    
    ref.removeValue { error, _ in
      handler(error)
    }
  }
}
