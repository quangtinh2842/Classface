//
//  NotificationsViewObserver.swift
//  Classface
//
//  Created by Soren Inis Ngo on 20/03/2026.
//

import Foundation
import SwiftUI

class NotificationsViewObserver: NSObject, ObservableObject {
  @Published var notifications: [CFNotification] = CFNotification.notificationsOfCurrentUser!
  @Published var junctions: [CFNotificationAndUser] = CFNotificationAndUser.junctionRecordsOfCurrentUser!
  
  func junctionIndexOf(notification: CFNotification) -> Int? {
    for (i, junction) in junctions.enumerated() {
      if notification.junctionId()! == junction.id! {
        return i
      }
    }
    
    return nil
  }
  
  func markAsReadAndUpdate2Sides(notificationAndUserJunctionId: String, completion handler: @escaping (Error?) -> Void) {
    for i in 0 ..< CFNotificationAndUser.junctionRecordsOfCurrentUser!.count {
      if CFNotificationAndUser.junctionRecordsOfCurrentUser![i].id == notificationAndUserJunctionId {
        CFNotificationAndUser.junctionRecordsOfCurrentUser![i].wasRead = true
        do {
          let _ = try CFNotificationAndUser.junctionRecordsOfCurrentUser![i].save(completion: { error, _ in
            if error != nil {
              handler(error)
              return
            } else {
              self.junctions = CFNotificationAndUser.junctionRecordsOfCurrentUser!
              handler(nil)
              return
            }
          })
        } catch {
          handler(error)
          return
        }
      }
    }
    
    MainTabViewObserver.shared.notifications = CFNotification.notificationsOfCurrentUser ?? []
    MainTabViewObserver.shared.junctions = CFNotificationAndUser.junctionRecordsOfCurrentUser ?? []
  }
  
  func fetchNotificationsAndJunctionsForAll(completion handler: @escaping (Error?) -> Void) {
    CFNotification.allNotificationsForCurrentUser { notifications, junctions, error in
      if error != nil {
        handler(error)
      } else {
        CFNotification.notificationsOfCurrentUser = notifications
        CFNotificationAndUser.junctionRecordsOfCurrentUser = junctions
        
        MainTabViewObserver.shared.notifications = CFNotification.notificationsOfCurrentUser!
        MainTabViewObserver.shared.junctions = CFNotificationAndUser.junctionRecordsOfCurrentUser!
        
        self.notifications = notifications
        self.junctions = junctions
        handler(nil)
      }
    }
  }
}
