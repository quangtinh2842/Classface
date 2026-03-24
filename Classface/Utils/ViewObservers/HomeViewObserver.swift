//
//  HomeViewObserver.swift
//  Classface
//
//  Created by Soren Inis Ngo on 21/03/2026.
//

import Foundation

class HomeViewObserver: NSObject, ObservableObject {
  @Published var allClasses: [CFClass] = [
    CFClass(cid: "c123", className: "Database", rollCallerId: CFUser.currentUserFromAuth!.uid!, backgroundURL: "https://athgroup.vn/upload/blocks/thumb_1920x0/ATH-phong-c%C3%A1ch-tr%E1%BB%ABu-t%C6%B0%E1%BB%A3ng-20.jpg", lecturerName: "Tinh Q. Ngo"),
    CFClass(cid: "c456", className: "Programming Language", rollCallerId: CFUser.currentUserFromAuth!.uid!, backgroundURL: "https://images.pexels.com/photos/1418595/pexels-photo-1418595.jpeg", lecturerName: "Tinh Q. Ngo"),
    CFClass(cid: "c789", className: "Swift Programming Language", rollCallerId: CFUser.currentUserFromAuth!.uid!, backgroundURL: "https://png.pngtree.com/thumb_back/fw800/background/20240522/pngtree-abstract-background-with-and-lines-different-shades-and-thickness-abstract-pattern-image_15683353.jpg", lecturerName: "Tinh Q. Ngo")
  ]
  
  static let shared = HomeViewObserver()
  
  private override init() { super.init() }
  
  func deleteOneClass(at offsets: IndexSet, completion handler: @escaping (Error?) -> Void) {
    offsets.map { allClasses[$0] }.forEach { cfClass in
      let classId = cfClass.cid!
      
      CFStudent.deleteWithId(classId) { error in
        if error != nil {
          handler(error)
        } else {
          self.allClasses.remove(atOffsets: offsets)
          handler(nil)
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
