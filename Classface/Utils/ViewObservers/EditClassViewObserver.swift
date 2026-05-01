//
//  EditClassViewObserver.swift
//  Classface
//
//  Created by Soren Inis Ngo on 22/03/2026.
//

import Foundation

class EditClassViewObserver: NSObject, ObservableObject {
  @Published var cid: String = ""
  @Published var className: String = ""
  @Published var rollCallerId: String = ""
  @Published var backgroundURL: String = ""
  @Published var lecturerName: String = ""
  
  @Published var students: [CFStudent] = []
  
  var studentsAfterSaving: [CFStudent] = []
  
  init(cfClass: CFClass?) {
    super.init()
    
    if cfClass == nil {
      self.cid = CFClass.getAutoId()
      self.rollCallerId = CFUser.currentUserFromAuth!.uid!
    } else {
      self.cid = cfClass!.cid!
      self.className = cfClass!.className!
      self.rollCallerId = cfClass!.rollCallerId!
      self.backgroundURL = cfClass!.backgroundURL!
      self.lecturerName = cfClass!.lecturerName!
            
      self.students = studentsForClassFromJunctions(classId: cfClass!.cid!)
      self.studentsAfterSaving = self.students
    }
  }
  
  private func studentsForClassFromJunctions(classId: String) -> [CFStudent] {
    var rst = [CFStudent]()
    
    for junction in CFClassAndStudent.allJunctionsOfCurrentUser {
      if junction.getCid() == classId {
        rst.append(junction.cfStudent()!)
      }
    }
    
    return rst
  }
  
  func editingClass() -> CFClass {
    return CFClass(cid: cid, className: className, rollCallerId: rollCallerId, backgroundURL: backgroundURL, lecturerName: lecturerName)
  }
}
