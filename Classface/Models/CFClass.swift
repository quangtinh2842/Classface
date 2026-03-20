//
//  CFClass.swift
//  Classface
//
//  Created by Soren Inis Ngo on 14/03/2026.
//

import Foundation

struct CFClass: CFBase {
  var cid: String?
  var className: String?
  var rollCallerId: String?
  
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
    
    if self.className == nil || self.className!.isEmpty {
      return (.InvalidBlankAttribute, "className")
    }
    
    return (.Valid, nil)
  }
}
