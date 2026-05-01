//
//  CFClass.swift
//  Classface
//
//  Created by Soren Inis Ngo on 14/03/2026.
//

import Foundation
import FirebaseDatabase

struct CFClass: CFBase {
  static let blankRecord: CFClass = {
    var cfClass = CFClass()
    
    cfClass.cid = ""
    cfClass.className = ""
    cfClass.rollCallerId = ""
    cfClass.backgroundURL = ""
    cfClass.lecturerName = ""
    
    return cfClass
  }()
  
  var cid: String?
  var className: String?
  var rollCallerId: String?
  var backgroundURL: String?
  var lecturerName: String?
  
  static func collectionName() -> String {
    return "classes"
  }
  
  static func primaryKey() -> String {
    return "cid"
  }
  
  var primaryKeyValue: String? {
    return cid
  }
  
  static func mapObject(jsonObject: NSDictionary) -> CFBase? {
    do {
      let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
      let decoder = JSONDecoder()
      let cfClass = try decoder.decode(CFClass.self, from: data)
      return cfClass
    } catch {
      return nil
    }
  }
  
  func validate() -> (ModelValidationError, String?) {
    if self.cid == nil || self.cid!.isEmpty ||
        self.rollCallerId == nil || self.rollCallerId!.isEmpty {
      return (.InvalidId, "cid, rollCallerId")
    }
    
    if self.className == nil || self.className!.isEmpty ||
        self.backgroundURL == nil || self.backgroundURL!.isEmpty ||
        self.lecturerName == nil || self.lecturerName!.isEmpty {
      return (.InvalidBlankAttribute, "className, backgroundURL, lecturerName")
    }
    
    return (.Valid, nil)
  }
  
  static func getAutoId() -> String {
    let ref = Database.database().reference().child(CFClass.collectionName()).childByAutoId()
    let autoID = ref.key
    return autoID!
  }
  
  static func allClassesForCurrentUser(completion handler: @escaping (Error?, [CFClass]) -> Void) {
    let queryClause: [QueryClausesEnum: AnyObject] = [
      .OrderedChildKey: "rollCallerId" as AnyObject,
      .ExactValue: CFUser.currentUserFromAuth!.uid! as AnyObject
    ]
    
    self.query(withClause: queryClause) { results, error in
      if error != nil {
        handler(error, [])
      } else {
        handler(nil, results as! [CFClass])
      }
    }
  }
  
  static func nStudentsOfClass(classId: String) -> Int {
    var studentIds: [String] = []
    
    for junction in CFClassAndStudent.allJunctionsOfCurrentUser {
      if junction.getCid() == classId {
        studentIds.append(junction.getSid())
      }
    }
    
    let idsSet = Set<String>(studentIds)
    
    return idsSet.count
  }
  
  func getStudentsOfClass() -> [CFStudent]  {
    var studentIds = [String]()
    
    for junction in CFClassAndStudent.allJunctionsOfCurrentUser {
      if junction.getCid() == cid {
        studentIds.append(junction.getSid())
      }
    }
    
    var result = [CFStudent]()
    
    for student in StudentsViewObserver.shared.allStudents {
      if studentIds.contains(student.sid!) {
        result.append(student)
      }
    }
    
    return result
  }
  
  func getStudentsInPhoto(photoURL: String) async throws -> [CFStudent] {
    let studentsOfClass = self.getStudentsOfClass()
    
    let photo = UIImage(data: try Data(contentsOf: URL(string: photoURL)!))!
    
    let faces: [UIImage] = try await withCheckedThrowingContinuation { continuation in
      CFFaceDetector.cropFacesFrom(image: photo) { error, croppedFaces in
        if let error = error {
          continuation.resume(throwing: error)
        } else {
          continuation.resume(returning: croppedFaces)
        }
      }
    }
    
    var vectorsOfFaces = [[Double]]()
    for face in faces {
      let vector = await FaceComparator.shared.vectorOf(face: CIImage(image: face)!)
      vectorsOfFaces.append(vector)
    }
    
    var vectorAndStudentArray: [(vector: [Double], student: CFStudent)] = []
    for student in studentsOfClass {
      let onlyStudentFace = try student.onlyStudentFace()!
      let vector = await FaceComparator.shared.vectorOf(face: onlyStudentFace)
      vectorAndStudentArray.append((vector, student))
    }
    
    var studentsInPhoto = [CFStudent]()
    for vectorOfFace in vectorsOfFaces {
      for vectorAndStudent in vectorAndStudentArray {
        if FaceComparator.shared.compare2Faces(v1: vectorOfFace, v2: vectorAndStudent.vector) {
          studentsInPhoto.append(vectorAndStudent.student)
        }
      }
    }
    
    return studentsInPhoto
  }
  
  static func getClassWith(cid: String) -> CFClass? {
    for cfClass in HomeViewObserver.shared.allClasses {
      if cfClass.cid! == cid {
        return cfClass
      }
    }
    
    return nil
  }
}
