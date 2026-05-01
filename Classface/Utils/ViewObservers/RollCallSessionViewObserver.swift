//
//  RollCallSessionViewObserver.swift
//  Classface
//
//  Created by Soren Inis Ngo on 25/03/2026.
//

import Foundation

class RollCallSessionViewObserver: NSObject, ObservableObject {
  @Published var rid: String = ""
  @Published var cid: String = ""
  @Published var sessionName: String = ""
  @Published var rollCallPhotos: [CFRollCallPhoto] = []
  
  init(rollCallSession: CFRollCallSession?, cid: String) {
    if rollCallSession != nil {
      self.rid = rollCallSession!.rid!
      self.cid = rollCallSession!.cid!
      self.sessionName = rollCallSession!.sessionName!
      self.rollCallPhotos = rollCallSession!.rollCallPhotos!
    } else {
      self.rid = CFRollCallSession.getAutoId()
      self.cid = cid
    }
  }
  
  func attendanceResult() -> String {
    let total = CFClass.nStudentsOfClass(classId: cid)
    
    var idsOfStudentsPresent: [String] = []
    
    for rollCallPhoto in rollCallPhotos {
      idsOfStudentsPresent.append(contentsOf: rollCallPhoto.idsOfStudentsPresent!)
    }
    
    let idsOfStudentsPresentSet = Set<String>(idsOfStudentsPresent)
    return "\(idsOfStudentsPresentSet.count)/\(total)"
  }
  
  func currentRollCallSession() -> CFRollCallSession {
    let rst = CFRollCallSession(rid: self.rid, cid: self.cid, sessionName: self.sessionName, rollCallPhotos: self.rollCallPhotos)
    return rst
  }
}
