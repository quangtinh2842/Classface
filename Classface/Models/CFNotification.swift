//
//  CFNotification.swift
//  Classface
//
//  Created by Soren Inis Ngo on 18/03/2026.
//

import Foundation
import FirebaseDatabase

struct CFNotification: CFBase {
  static var notificationsOfCurrentUser: [CFNotification]?
  
  var nid: String?
  var iconURL: URL?
  var title: String?
  var content: String?
  var time: Date?
  
  static func collectionName() -> String {
    return "notifications"
  }
  
  static func primaryKey() -> String {
    return "nid"
  }
  
  var primaryKeyValue: String? {
    return nid
  }
  
  static func mapObject(jsonObject: NSDictionary) -> CFBase? {
    do {
      let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
      
      let decoder = JSONDecoder()
      
      let notification = try decoder.decode(CFNotification.self, from: data)
      
      return notification
    } catch {
      return nil
    }
  }
  
  func validate() -> (ModelValidationError, String?) {
    if self.nid == nil || self.nid!.isEmpty {
      return (.InvalidId, "nid")
    }
    
    if self.time == nil {
      return (.InvalidBlankAttribute, "time")
    }
    
    return (.Valid, nil)
  }
  
  static func allNotificationsForCurrentUser(completion handler: @escaping NotificationHandler) {
    let currentUser = CFUser.currentUserFromAuth
    
    let queryClause: [QueryClausesEnum: AnyObject] = [
      QueryClausesEnum.OrderedChildKey: currentUser!.uid! as AnyObject,
      QueryClausesEnum.ExactValue: true as AnyObject
    ]
    
    CFNotificationAndUser.query(withClause: queryClause) { results, error in
      if error != nil {
        handler([], [], error)
        return
      }
      
      let notificationAndUserJunctionRecords = results as! [CFNotificationAndUser]
      let notificationIds = notificationAndUserJunctionRecords.map { $0.getNid() }
      
      if notificationIds.isEmpty {
        handler([], [], NotFoundError)
        return
      }
      
      let uniqueNotificationIdsSet = Set<String>(notificationIds)
      let uniqueNotificationIds = [String](uniqueNotificationIdsSet).sorted()
      
      self.retrieveNotifications(fromIds: uniqueNotificationIds, junctions: notificationAndUserJunctionRecords, completion: handler)
    }
  }
  
  static func retrieveNotifications(fromIds notificationIds: [String], junctions: [CFNotificationAndUser], completion handler: @escaping NotificationHandler) {
    let queryClause: [QueryClausesEnum: AnyObject] = [
      .OrderedChildKey: "nid" as AnyObject,
      .StartValue: notificationIds.first! as AnyObject,
      .EndValue: notificationIds.last! as AnyObject
    ]
    
    self.query(withClause: queryClause) { notifications, error in
      if error != nil {
        handler([], junctions, error)
        return
      }
      
      let filteredNotifications = (notifications as! [CFNotification]).filter { notificationIds.contains($0.nid!) }.sorted { $0.time?.compare($1.time!) == .orderedDescending }
      
      handler(filteredNotifications, junctions, nil)
    }
  }
  
  var notificationAndUserJunctionRecordKey: String? {
    if self.nid == nil || CFUser.currentUserFromAuth == nil {
      return nil
    } else {
      return self.nid! + "_" + CFUser.currentUserFromAuth!.uid!
    }
  }
}
