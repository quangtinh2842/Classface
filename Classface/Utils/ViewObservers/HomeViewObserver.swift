//
//  HomeViewObserver.swift
//  Classface
//
//  Created by Soren Inis Ngo on 21/03/2026.
//

import Foundation

class HomeViewObserver: NSObject, ObservableObject {
  @Published var allClasses: [CFClass] = []
  
  static let shared = HomeViewObserver()
  
  private override init() { super.init() }
  
  func deleteOneClass(at offsets: IndexSet, completion handler: @escaping (Error?) -> Void) {
    offsets.map { allClasses[$0] }.forEach { cfClass in
      let classId = cfClass.cid!
      
      CFClass.deleteWithId(classId) { error in
        if error != nil {
          handler(error)
        } else {
          CFClassAndStudent.deleteJunctionsRelativedTo(cfClass: cfClass) { error2 in
            if error2 != nil {
              handler(error2)
            } else {
              CFClassAndStudent.fetchAllJunctionsForClasses(classIds: HomeViewObserver.shared.allClasses.map { $0.cid! }) { error3, allJunctionsOfCurrentUser in
                if error3 != nil {
                  handler(error3)
                } else {
                  CFClassAndStudent.allJunctionsOfCurrentUser = allJunctionsOfCurrentUser
                  
                  self.allClasses.remove(atOffsets: offsets)
                  handler(nil)
                }
              }
            }
          }
        }
      }
    }
  }
  
  func updateLocal(cfClass: CFClass) {
    for (i, _) in allClasses.enumerated() {
      if allClasses[i].cid! == cfClass.cid! {
        allClasses[i] = cfClass
        return
      }
    }
    
    allClasses.append(cfClass)
    return
  }
}
