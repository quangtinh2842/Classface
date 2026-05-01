//
//  CFBase.swift
//  Classface
//
//  Created by Soren Inis Ngo on 14/03/2026.
//

import Foundation
import FirebaseDatabase

protocol CFBase: Codable {
  static func collectionName() -> String
  
  static func primaryKey() -> String
  
  var primaryKeyValue: String? { get }
  
  static func mapObject(jsonObject: NSDictionary) -> CFBase?
  
  func validate() -> (ModelValidationError, String?)
  
  static func find(byId objectId: String, completion handler: @escaping ObjectQueryResultHandler)
  
  static func query(withClause queryClause: [QueryClausesEnum: AnyObject]?, completion handler: @escaping CollectionQueryResultHandler)
  
  func save(completion handler: UpdateValueHandler?) throws -> String
}

extension CFBase {
  func toJSON() -> [String: Any]? {
    do {
      let data = try JSONEncoder().encode(self)
      
      let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
      
      return json as? [String: Any]
    } catch {
      return nil
    }
  }
  
  static func deleteWithId(_ id: String, completion handler: @escaping (Error?) -> Void) {
    let ref = Database.database().reference().child(collectionName()).child(id)
    
    ref.removeValue { error, _ in
      handler(error)
    }
  }
  
  static func find(byId objectId: String, completion handler: @escaping ObjectQueryResultHandler) {
    let dbRef = Database.database().reference()
    let collectionName = self.collectionName()
    
    let query = dbRef.child("\(collectionName)/\(objectId)")
    
    query.observeSingleEvent(of: .value, with: { (snapshot) in
      if !(snapshot.value is NSDictionary) {
        handler(nil, NotFoundError)
        return
      }
      
      let resultDict = snapshot.value as! NSDictionary
      let resultModel = self.mapObject(jsonObject: resultDict)
      handler(resultModel, nil)
    }) { (error) in
      handler(nil, error)
    }
  }
  
  static func query(withClause queryClause: [QueryClausesEnum: AnyObject]?, completion handler: @escaping CollectionQueryResultHandler) {
    let dbRef = Database.database().reference()
    let collectionName = self.collectionName()
    
    var query = dbRef.child(collectionName) as DatabaseQuery
    
    if queryClause != nil {
      if let orderedChildKey = queryClause![.OrderedChildKey] {
        query = query.queryOrdered(byChild: orderedChildKey as! String)
      }
      
      if let startValue = queryClause![.StartValue] {
        query = query.queryStarting(atValue: startValue)
      }
      
      if let endValue = queryClause![.EndValue] {
        query = query.queryEnding(atValue: endValue)
      }
      
      if let exactValue = queryClause![.ExactValue] {
        query = query.queryEqual(toValue: exactValue)
      }
    }
    
    query.observeSingleEvent(of: .value, with: { snapshot in
      if !(snapshot.value is NSDictionary) {
        handler([], NotFoundError)
        return
      }
      
      var resultModels: [CFBase] = []
      let results = snapshot.value as! [String: NSDictionary]
      
      for (_, resultDict) in results {
        let resultModel = self.mapObject(jsonObject: resultDict)
        
        if resultModel != nil {
          resultModels.append(resultModel!)
        }
      }
      
      handler(resultModels, nil)
    }) { (error) in
      handler([], error)
    }
  }
  
  func save(completion handler: UpdateValueHandler? = nil) throws -> String {
    let (validation, errors) = self.validate()
    let errorDomain = "Model validation failed"
    
    switch validation {
    case .Valid: break
    case .InvalidId:
      throw NSError(domain: errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "IDs \(errors!) must not be blank"])
    case .InvalidTimestamp:
      throw NSError(domain: errorDomain, code: -2, userInfo: [NSLocalizedDescriptionKey: "Timestamps \(errors!) must not be blank"])
    case .InvalidBlankAttribute:
      throw NSError(domain: errorDomain, code: -3, userInfo: [NSLocalizedDescriptionKey: "Attributes \(errors!) must not be blank"])
    }
    
    let dbRef = Database.database().reference()
    let collectionName = type(of: self).collectionName()
    let primaryKey = type(of: self).primaryKey()
    
    var objectId = ""
    
    if let primaryKeyValue = self.primaryKeyValue {
      objectId = self._saveAsUpdate(inDb: dbRef, inCollection: collectionName, withId: primaryKeyValue, completion: handler)
    } else {
      objectId = self._saveAsNew(inDb: dbRef, inCollection: collectionName, withPrimaryKey: primaryKey, completion: handler)
    }
    
    return objectId
  }
  
  private func _saveAsUpdate(inDb dbRef: DatabaseReference, inCollection colName: String, withId objectId: String, completion handler: UpdateValueHandler?) -> String {
    let objectJson = self.toJSON()
    let updatesManifest = ["/\(colName)/\(objectId)": objectJson]
    
    if handler != nil {
      dbRef.updateChildValues(updatesManifest, withCompletionBlock: handler!)
    } else {
      dbRef.updateChildValues(updatesManifest)
    }
    
    return objectId
  }
  
  private func _saveAsNew(inDb dbRef: DatabaseReference, inCollection colName: String, withPrimaryKey primaryKey: String, completion handler: UpdateValueHandler?) -> String {
    let objectId = dbRef.child(colName).childByAutoId().key!
    
    var objectJson = self.toJSON()!
    objectJson[primaryKey] = objectId
    
    let updatesManifest = ["/\(colName)/\(objectId)": objectJson]
    
    if handler != nil {
      dbRef.updateChildValues(updatesManifest, withCompletionBlock: handler!)
    } else {
      dbRef.updateChildValues(updatesManifest)
    }
    
    return objectId
  }
}
