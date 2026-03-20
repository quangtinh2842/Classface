//
//  MainEntryView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 13/03/2026.
//

import SwiftUI

struct MainEntryView: View {
  @State var showSignUp = false
  
  @Binding var user: CFUser?
    
  var body: some View {
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
}

struct MainEntryView_Previews: PreviewProvider {
  static var previews: some View {
    MainEntryView(user: .constant(CFUser.mockUser))
  }
}
