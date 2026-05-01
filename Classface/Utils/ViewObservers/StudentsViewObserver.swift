//
//  StudentsViewObserver.swift
//  Classface
//
//  Created by Soren Inis Ngo on 22/03/2026.
//

import Foundation

class StudentsViewObserver: NSObject, ObservableObject {
  @Published var allStudents: [CFStudent] = [
    CFStudent(sid: "123", name: "Tom", photoURL: "https://images2.thanhnien.vn/zoom/686_429/Uploaded/myquyen/2017_09_22/hotboy_ERBA.jpg"),
    CFStudent(sid: "234", name: "Tim", photoURL: "https://cdn.tienphong.vn/images/acaaf3972f12824005b323aa5fc6b75a139e60778ea39f3cb8836eb89ab38428fce64629cbd2f04f4700b29c6a1ced9e4b92013eeda7b45126673d4926a68b13/dung3_qjqv.jpeg"),
    CFStudent(sid: "345", name: "Anna", photoURL: "https://www.mordeo.org/files/uploads/2018/09/Cute-Dream-Asian-Girl-4K-Ultra-HD-Mobile-Wallpaper-950x1689.jpg"),
  ]
  
  static let shared = StudentsViewObserver()
  
  private override init() { super.init() }
  
  func deleteOneStudent(at offsets: IndexSet, completion handler: @escaping (Error?) -> Void) {
    offsets.map { allStudents[$0] }.forEach { student in
      let studentId = student.sid!
      
      CFStudent.deleteWithId(studentId) { error in
        if error != nil {
          handler(error)
        } else {
          CFClassAndStudent.deleteJunctionsRelativedTo(cfStudent: student) { error2 in
            if error2 != nil {
              handler(error2)
            } else {
              CFClassAndStudent.fetchAllJunctionsForClasses(classIds: HomeViewObserver.shared.allClasses.map { $0.cid! }) { error3, allJunctionsOfCurrentUser in
                if error3 != nil {
                  handler(error3)
                } else {
                  CFClassAndStudent.allJunctionsOfCurrentUser = allJunctionsOfCurrentUser
                  
                  self.allStudents.remove(atOffsets: offsets)
                  handler(nil)
                }
              }
            }
          }
        }
      }
    }
  }
  
  func updateLocal(student: CFStudent) {
    for (i, _) in allStudents.enumerated() {
      if allStudents[i].sid! == student.sid! {
        allStudents[i] = student
        return
      }
    }
    
    allStudents.append(student)
    return
  }
}
