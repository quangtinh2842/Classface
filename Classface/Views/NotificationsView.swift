//
//  NotificationsView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 15/03/2026.
//

import SwiftUI

struct NotificationsView: View {
  var body: some View {
    NavigationView {
      VStack {
        List(CFNotification.notificationsOfCurrentUser!, id: \.nid) { notification in
          notificationRow(notification)
        }
      }
    }
  }
  
  func notificationRow(_ notification: CFNotification) -> some View {
    HStack {
      Image(
    }
  }
}

struct NotificationsView_Previews: PreviewProvider {
  static var previews: some View {
    NotificationsView()
  }
}

