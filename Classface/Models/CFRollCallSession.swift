//
//  CFRollCallSession.swift
//  Classface
//
//  Created by Soren Inis Ngo on 25/03/2026.
//

import Foundation
import FirebaseDatabase

struct CFRollCallSession: CFBase {
  static var allRollCallSessionsRelatedToCurrentUser: [CFRollCallSession]?
  
  var rid: String?
  var cid: String?
  var sessionName: String?
  var rollCallPhotos: [CFRollCallPhoto]?
  
  static func collectionName() -> String {
    return "roll_call_sessions"
  }
  
  static func primaryKey() -> String {
    return "rid"
  }
  
  var primaryKeyValue: String? {
    return rid
  }
  
  static func mapObject(jsonObject: NSDictionary) -> CFBase? {
    do {
      let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
      let decoder = JSONDecoder()
      let sessionRecord = try decoder.decode(CFRollCallSession.self, from: data)
      return sessionRecord
    } catch {
      return nil
    }
  }
  
  func validate() -> (ModelValidationError, String?) {
    if self.rid == nil || self.rid!.isEmpty ||
        self.cid == nil || self.cid!.isEmpty {
      return (.InvalidId, "rid, cid")
    }
    
    if self.sessionName == nil || self.sessionName!.isEmpty {
      return (.InvalidBlankAttribute, "sessionName")
    }
    
    return (.Valid, nil)
  }
  
  static func fetchAllRollCallSessionsRelatedToCurrentUser(completion handler: @escaping (Error?, [CFRollCallSession]) -> Void) {
    let classIds = HomeViewObserver.shared.allClasses.map { $0.cid! }
    
    self.query(withClause: nil) { results, error in
      if error != nil {
        handler(error, [])
      } else {
        let all = results as! [CFRollCallSession]
        var relativeSessions = [CFRollCallSession]()
        
        for session in all {
          if classIds.contains(session.cid!) {
            relativeSessions.append(session)
          }
        }
        
        handler(nil, relativeSessions)
      }
    }
  }
  
  static func getAutoId() -> String {
    let ref = Database.database().reference().child(CFRollCallSession.collectionName()).childByAutoId()
    let autoID = ref.key
    return autoID!
  }
  
  func nAttendanceStudents() -> Int {
    var sids = [String]()
    
    for rollCallPhoto in rollCallPhotos ?? [] {
      sids.append(contentsOf: rollCallPhoto.idsOfStudentsPresent ?? [])
    }
    
    let setOfSids = Set<String>(sids)
    return setOfSids.count
  }
  
  func attendanceResult() -> String {
    let cfClass = CFClass.getClassWith(cid: cid!)!
    let studentsOfClass = cfClass.getStudentsOfClass()
    return "\(String(self.nAttendanceStudents()))/\(String(studentsOfClass.count))"
  }
  
  static func rollCallSessionsOfClass(cid: String) -> [CFRollCallSession] {
    var rst = [CFRollCallSession]()
    
    for rollCallSession in CFRollCallSession.allRollCallSessionsRelatedToCurrentUser! {
      if rollCallSession.cid! == cid {
        rst.append(rollCallSession)
      }
    }
    
    return rst
  }
  
  static func updateForGlobalArray(rollCallSession: CFRollCallSession) {
    let rids = CFRollCallSession.allRollCallSessionsRelatedToCurrentUser!.map { $0.rid! }
    if rids.contains(rollCallSession.rid!) {
      for (i, _) in CFRollCallSession.allRollCallSessionsRelatedToCurrentUser!.enumerated() {
        if CFRollCallSession.allRollCallSessionsRelatedToCurrentUser![i].rid! == rollCallSession.rid! {
          CFRollCallSession.allRollCallSessionsRelatedToCurrentUser![i] = rollCallSession
        }
      }
    } else {
      CFRollCallSession.allRollCallSessionsRelatedToCurrentUser?.append(rollCallSession)
    }
  }
}
