//
//  MainEntryView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 13/03/2026.
//

import SwiftUI
import AlertToast

struct MainEntryView: View {
  @StateObject var network = NetworkMonitor()
  @State var showToast = false
  @State var toast: AlertToast = AlertToast(displayMode: .hud, type: .systemImage("wifi.slash", .yellow), subTitle: "No network connection.")
  
  @State var showSignUp = false
  
  @Binding var user: CFUser?
  
  var body: some View {
    VStack {
      if self.user != nil {
        MainTabView(user: self.$user)
      } else {
        if showSignUp {
          SignUpView(showSignUp: $showSignUp, user: self.$user)
        } else {
          LogInView(showSignUp: $showSignUp, user: $user)
        }
      }
    }
    .onChange(of: network.isConnected) { connected in
      self.showToast = !connected
      
      if connected {
        // call sync here
      }
    }
    .toast(isPresenting: $showToast, duration: .infinity, tapToDismiss: false, alert: {
      return toast
    })
  }
}

struct MainEntryView_Previews: PreviewProvider {
  static var previews: some View {
    MainEntryView(user: .constant(CFUser.mockUser))
  }
}
