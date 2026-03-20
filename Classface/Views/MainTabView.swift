//
//  MainTabView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 13/03/2026.
//

import SwiftUI

struct MainTabView: View {
  @Binding var user: CFUser?
  
  var body: some View {
    TabView {
      HomeView()
        .tabItem {
          Label("", systemImage: "house.fill")
        }
      NotificationsView()
        .tabItem {
          Label("", systemImage: "bell.fill")
        }
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
