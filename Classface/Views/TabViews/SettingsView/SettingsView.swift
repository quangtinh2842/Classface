//
//  SettingsView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 15/03/2026.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth

struct SettingsView: View {
  @Binding var user: CFUser?
  
  var body: some View {
    NavigationView {
      List {
        Section(header: Text("About")) {
          NavigationLink(destination: TOSView()) {
            HStack(spacing: 16) {
              Image(systemName: "doc.text")
                .foregroundColor(Color(.gray))
              Text("Terms of Service")
                .foregroundColor(Color(.label))
                .fontWeight(.medium)
            }
          }
        }
        
        Section(header: Text("Development")) {
          NavigationLink(destination: ResourcesView()) {
            HStack(spacing: 16) {
              Image(systemName: "heart")
                .foregroundColor(Color(.gray))
              Text("Resources")
                .foregroundColor(Color(.label))
                .fontWeight(.medium)
            }
          }
        }
        
        Section(header: Text("Actions")) {
          Button {
            CFUser.signOutEverywhere()
            self.user = nil
          } label: {
            HStack(spacing: 16) {
              Image(systemName: "rectangle.portrait.and.arrow.right")
                .foregroundColor(Color(.gray))
              Text("Log out")
                .foregroundColor(Color(.label))
                .fontWeight(.medium)
            }
          }
        }
      }
      .navigationTitle("Settings")
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView(user: .constant(CFUser.mockUser))
  }
}
