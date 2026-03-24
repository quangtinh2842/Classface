//
//  CFStudent.swift
//  Classface
//
//  Created by Soren Inis Ngo on 14/03/2026.
//

import Foundation
import FirebaseDatabase

struct CFStudent: CFBase {
  static let blankRecord: CFStudent = {
    var cfStudent = CFStudent()
    cfStudent.sid = ""
    cfStudent.photoURL = ""
    cfStudent.name = ""
    cfStudent.rollCallerId = CFUser.currentUserFromAuth?.uid
    return cfStudent
  }()
  
  var sid: String?
  var name: String?
  var photoURL: String?
  var rollCallerId: String?
  
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
    if self.sid == nil || self.sid!.isEmpty ||
        self.rollCallerId == nil || self.rollCallerId!.isEmpty {
      return (.InvalidId, "sid, rollCallerId")
    }
    
    if self.name == nil || self.name!.isEmpty ||
        self.photoURL == nil || self.photoURL!.isEmpty {
      return (.InvalidBlankAttribute, "name, photoURL")
    }
    
    return (.Valid, nil)
  }
  
  static func getAutoId() -> String {
    let ref = Database.database().reference().child(CFStudent.collectionName()).childByAutoId()
    let autoID = ref.key
    return autoID!
  }
  
  static func allStudentsForCurrentUser(completion handler: @escaping (Error?) -> Void) {
    let queryClause: [QueryClausesEnum: AnyObject] = [
      .OrderedChildKey: "rollCallerId" as AnyObject,
      .ExactValue: CFUser.currentUserFromAuth!.uid! as AnyObject
    ]
    
    self.query(withClause: queryClause) { results, error in
      if error != nil {
        handler(error)
        return
      } else {
        let allStudents = results as! [CFStudent]
        StudentsViewObserver.shared.allStudents = allStudents
        handler(nil)
        return
      }
    }
  }
  
  static func deleteWithId(_ id: String, completion handler: @escaping (Error?) -> Void) {
    let ref = Database.database().reference().child(CFStudent.collectionName()).child(id)
    
    ref.removeValue { error, _ in
      handler(error)
    }
  }
}
