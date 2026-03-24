//
//  MainTabView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 13/03/2026.
//

import SwiftUI

struct MainTabView: View {
  @StateObject private var _observer = MainTabViewObserver.shared
  
  @Binding var user: CFUser?
  
  var body: some View {
    TabView {
      HomeView()
        .tabItem {
          Label("", systemImage: "house.fill")
        }
      StudentsView()
        .tabItem {
          Label("", systemImage: "person.2.fill")
        }
      NotificationsView()
        .tabItem {
          Label("", systemImage: "bell.fill")
        }
        .badge(_observer.nUnreadNotifications())
      SettingsView(user: self.$user)
        .tabItem {
          Label("", systemImage: "gearshape.fill")
        }
      ProfileView()
        .tabItem {
          Label("", systemImage: "person.crop.circle.fill")
        }
    }
  }
}

struct MainTabView_Previews: PreviewProvider {
  static var previews: some View {
    MainTabView(user: .constant(CFUser.mockUser))
  }
}
