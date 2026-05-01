//
//  CFClassAndStudent.swift
//  Classface
//
//  Created by Soren Inis Ngo on 14/03/2026.
//

import Foundation
import FirebaseDatabase

struct CFClassAndStudent: CFBase {
  static var allJunctionsOfCurrentUser: [CFClassAndStudent] = []
  
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
  
  func getCid() -> String {
    let startIndex = self.id!.startIndex
    let endIndex = self.id!.index(startIndex, offsetBy: 20)
    
    return String(self.id![startIndex..<endIndex])
  }
  
  func getSid() -> String {
    let startIndex = self.id!.index(self.id!.startIndex, offsetBy: 21)
    
    return String(self.id![startIndex...])
  }
  
  func cfClass() -> CFClass? {
    for cfClass in HomeViewObserver.shared.allClasses {
      if cfClass.cid == self.getCid() {
        return cfClass
      }
    }
    
    return nil
  }
  
  func cfStudent() -> CFStudent? {
    for student in StudentsViewObserver.shared.allStudents {
      if student.sid == self.getSid() {
        return student
      }
    }
    
    return nil
  }
  
  static func fetchAllJunctionsForClasses(classIds: [String], completion handler: @escaping (Error?, [CFClassAndStudent]) -> Void) {
    let group = DispatchGroup()
    var firstError: Error?
    var junctions: [CFClassAndStudent] = []
    
    for classId in classIds {
      guard firstError == nil else { break }
      
      group.enter()
      
      let queryClause: [QueryClausesEnum: AnyObject] = [
        QueryClausesEnum.OrderedChildKey: classId as AnyObject,
        QueryClausesEnum.ExactValue: true as AnyObject
      ]
      
      CFClassAndStudent.query(withClause: queryClause) { results, error in
        if let error = error, firstError == nil {
          if (error as NSError).domain != NotFoundError.domain {
            firstError = error
          }
        } else {
          let array = results as! [CFClassAndStudent]
          junctions.append(contentsOf: array)
        }
        
        group.leave()
      }
    }
    
    group.notify(queue: .main) {
      if firstError == nil {
        handler(nil, junctions)
      } else {
        handler(firstError, [])
      }
    }
  }
  
  static func saveWith(cid: String, sid: String, completion handler: @escaping (Error?) -> Void) {
    var record = [String: AnyObject]()
    record[cid] = true as AnyObject
    record[sid] = true as AnyObject
    record["id"] = (cid + "_" + sid) as AnyObject
    
    let updatesManifest = ["/\(CFClassAndStudent.collectionName())/\(record["id"]!)": record]
    let dbRef = Database.database().reference()
    dbRef.updateChildValues(updatesManifest)
    
    handler(nil)
  }
  
  static func deleteJunctionsRelativedTo(cfClass: CFClass, completion handler: @escaping (Error?) -> Void) {
    var relativedJunctions = [CFClassAndStudent]()
    
    for junction in allJunctionsOfCurrentUser {
      if junction.getCid() == cfClass.cid! {
        relativedJunctions.append(junction)
      }
    }
    
    let group = DispatchGroup()
    var firstError: Error?
    
    for junction in relativedJunctions {
      guard firstError == nil else { break }
      
      group.enter()
      
      CFClassAndStudent.deleteWithId(junction.id!) { error in
        if let error = error, firstError == nil {
          firstError = error
        }
        
        group.leave()
      }
    }
    
    group.notify(queue: .main) {
      handler(firstError)
    }
  }
  
  static func deleteJunctionsRelativedTo(cfStudent: CFStudent, completion handler: @escaping (Error?) -> Void) {
    var relativedJunctions = [CFClassAndStudent]()
    
    for junction in allJunctionsOfCurrentUser {
      if junction.getSid() == cfStudent.sid! {
        relativedJunctions.append(junction)
      }
    }
    
    let group = DispatchGroup()
    var firstError: Error?
    
    for junction in relativedJunctions {
      guard firstError == nil else { break }
      
      group.enter()
      
      CFClassAndStudent.deleteWithId(junction.id!) { error in
        if let error = error, firstError == nil {
          firstError = error
        }
        
        group.leave()
      }
    }
    
    group.notify(queue: .main) {
      handler(firstError)
    }
  }
}
