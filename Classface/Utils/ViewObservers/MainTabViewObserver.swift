//
//  MainTabViewObserver.swift
//  Classface
//
//  Created by Soren Inis Ngo on 21/03/2026.
//

import Foundation

class MainTabViewObserver: NSObject, ObservableObject {
  @Published var notifications: [CFNotification] = CFNotification.notificationsOfCurrentUser!
  @Published var junctions: [CFNotificationAndUser] = CFNotificationAndUser.junctionRecordsOfCurrentUser!
  
  static let shared = MainTabViewObserver()
  
  private override init() { super.init() }
  
  func nUnreadNotifications() -> Int {
    var count = 0
    
    for junction in junctions {
      if !junction.wasRead {
        count += 1
      }
    }
    
    return count
  }
}
