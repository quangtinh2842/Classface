//
//  NotificationsView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 15/03/2026.
//

import SwiftUI
import Kingfisher
import AlertToast

struct NotificationsView: View {
  @StateObject private var _observer = NotificationsViewObserver()
  
  @State var showToast = false
  @State var toast: AlertToast = AlertToast(displayMode: .alert, type: .regular)
  
  var body: some View {
    NavigationView {
      VStack {
        List {
          ForEach(0..<_observer.notifications.count, id: \.self) { index in
            let notification = _observer.notifications[index]
            
            notificationRow(notification)
              .onTapGesture {
                if !_observer.junctions[_observer.junctionIndexOf(notification: notification)!].wasRead {
                  _observer.markAsReadAndUpdate2Sides(notificationAndUserJunctionId: notification.junctionId()!) { error in
                    if error != nil {
                      toast = AlertToast(displayMode: .banner(.pop), type: .error(.red), title: "Error", subTitle: error!.localizedDescription)
                      showToast = true
                    }
                  }
                }
              }
          }
        }
        .refreshable {
          await withCheckedContinuation { continuation in
            Task {
              try? await sleepWith(duration: 1)
              _observer.fetchNotificationsAndJunctionsForAll { error in
                continuation.resume()
                
                if error != nil {
                  toast = AlertToast(displayMode: .banner(.pop), type: .error(.red), title: "Error", subTitle: error!.localizedDescription)
                  showToast = true
                }
              }
            }
          }
        }
      }
      .navigationTitle(Text("Notifications"))
      .toast(isPresenting: $showToast, alert: {
        return toast
      })
    }
  }
  
  func notificationRow(_ notification: CFNotification) -> some View {
    HStack(spacing: 8) {
      ZStack(alignment: .topLeading) {
        KFImage(notification.iconURL ?? URL(string: "https://raw.githubusercontent.com/quangtinh2842/PublicStore/refs/heads/main/Icons/identity_platform_1000dp_434343_FILL0_wght400_GRAD0_opsz48.png"))
          .placeholder {
            Image(systemName: "bell.fill")
              .foregroundColor(.gray)
          }
          .resizable()
          .cacheOriginalImage()
          .scaledToFill()
          .frame(width: 60, height: 60)
        
        if !_observer.junctions[_observer.junctionIndexOf(notification: notification)!].wasRead {
          Circle()
            .frame(width: 10, height: 10)
            .foregroundColor(.red)
        }
      }
      
      VStack(alignment: .leading) {
        HStack(alignment: .top, spacing: 0) {
          Text(notification.title!)
            .font(.headline)
          Spacer()
          HStack(spacing: 0) {
            Text(timeAgoSince(notification.time!))
          }
          .font(.caption2)
          .fixedSize(horizontal: true, vertical: false)
        }
        Text(notification.content!)
          .font(.subheadline)
      }
    }
  }
}

struct NotificationsView_Previews: PreviewProvider {
  static var previews: some View {
    NotificationsView()
  }
}
