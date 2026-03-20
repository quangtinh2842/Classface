//
//  CFClassAndStudent.swift
//  Classface
//
//  Created by Soren Inis Ngo on 14/03/2026.
//

import Foundation

struct CFClassAndStudent: CFBase {
//  "class_1_id_student_1_id": {
//    "class_1_id": true,
//    "student_1_id": true
//    "id": "class_1_id_student_1_id"
//  }
  
  var id: String?
  
  static func collectionName() -> String {
    return "class_and_student_junction_records"
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
      let junctionRecord = try decoder.decode(CFClassAndStudent.self, from: data)
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
}
