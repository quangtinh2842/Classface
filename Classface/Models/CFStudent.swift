//
//  CFStudent.swift
//  Classface
//
//  Created by Soren Inis Ngo on 14/03/2026.
//

import Foundation

struct CFStudent: CFBase {
  var sid: String?
  var name: String?
  
  static func collectionName() -> String {
    return "students"
  }
  
  static func primaryKey() -> String {
    return "sid"
  }
  
  var primaryKeyValue: String? {
    return sid
  }
  
  static func mapObject(jsonObject: NSDictionary) -> CFBase? {
    do {
      let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
      let decoder = JSONDecoder()
      let student = try decoder.decode(CFStudent.self, from: data)
      return student
    } catch {
      return nil
    }
  }
  
  func validate() -> (ModelValidationError, String?) {
    if self.sid == nil || self.sid!.isEmpty {
      return (.InvalidId, "sid")
    }
    
    if self.name == nil || self.name!.isEmpty {
      return (.InvalidBlankAttribute, "name")
    }
    
    return (.Valid, nil)
  }
}
