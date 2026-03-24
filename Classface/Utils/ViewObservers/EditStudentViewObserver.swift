//
//  EditStudentViewObserver.swift
//  Classface
//
//  Created by Soren Inis Ngo on 22/03/2026.
//

import Foundation

class EditStudentViewObserver: NSObject, ObservableObject {
  @Published var sid: String
  @Published var photoURL: String
  @Published var name: String
  
  init(student: CFStudent?) {
    let tmp = student ?? CFStudent.blankRecord
    sid = tmp.sid!
    
    if student == nil {
      sid = CFStudent.getAutoId()
    }
    
    photoURL = tmp.photoURL!
    name = tmp.name!
  }
  
  func editingStudent() -> CFStudent {
    return CFStudent(sid: sid, name: name, photoURL: photoURL, rollCallerId: CFUser.currentUserFromAuth?.uid)
  }
}
