//
//  ProfileView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 15/03/2026.
//

import SwiftUI
import Kingfisher
import HUD
import Toaster

struct ProfileView: View {
  @StateObject private var _observerForEditPopUp = ProfileViewObserver(user: CFUser.currentUserFromDb!)
  @StateObject private var _observer = ProfileViewObserver(user: CFUser.currentUserFromDb!)
  
  @State private var _isShowingEditPopUp = false
  
  @State var hudState: HUDState?
  
  var body: some View {
    ZStack(alignment: .center) {
      NavigationView {
        mainContent()
          .navigationTitle("Profile")
      }
      .blur(radius: _isShowingEditPopUp ? 5 : 0)
      
      if _isShowingEditPopUp {
        Color.black.opacity(0.4)
          .ignoresSafeArea()
          .onTapGesture {
            withAnimation {
              _isShowingEditPopUp = false
            }
          }
        theEditPopUp()
      }
    }
    .ignoresSafeArea()
    .overlayHUD($hudState)
  }
  
  func mainContent() -> some View {
    List {
      Section {
        Button {
          withAnimation {
            _isShowingEditPopUp.toggle()
          }
        } label: {
          HStack(spacing: 10) {
            KFImage(URL(string: _observer.photoURL) ?? URL(string: "https://raw.githubusercontent.com/quangtinh2842/PublicStore/refs/heads/main/Icons/account_circle_1000dp_434343_FILL0_wght400_GRAD0_opsz48.png"))
              .placeholder {
                Image(systemName: "person.circle.fill")
                  .foregroundColor(.gray)
              }
              .resizable()
              .cacheOriginalImage()
              .scaledToFill()
              .frame(width: 60, height: 60)
              .clipShape(Circle())
            
            VStack(alignment: .leading) {
              Text(_observer.fullName)
                .font(.system(size: 24))
                .foregroundColor(Color(.label))
              Text(_observer.email)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            }
          }
        }
      }
      
      Section {
        Text("UID: "+_observer.uid)
          .foregroundColor(Color(.gray))
      }
    }
  }
  
  func theEditPopUp() -> some View {
    VStack {
      VStack(alignment: .leading, spacing: 0) {
        Text("Photo URL")
        TextField("Photo URL", text: $_observerForEditPopUp.photoURL).textFieldStyle(.roundedBorder)
      }
      
      VStack(alignment: .leading, spacing: 0) {
        Text("Full Name")
        TextField("Full Name", text: $_observerForEditPopUp.fullName).textFieldStyle(.roundedBorder)
      }
      
      VStack(alignment: .leading, spacing: 0) {
        Text("Email Address")
        TextField("Email Address", text: $_observerForEditPopUp.email).textFieldStyle(.roundedBorder)
          .disabled(true)
      }
      
      Button {
        updateNewProfile()
      } label: {
        Text("Update")
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
          .foregroundColor(.white)
          .background(Color(.tintColor))
          .cornerRadius(8)
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 16)
    .background(Color(.systemBackground))
    .cornerRadius(8)
    .shadow(radius: 8)
    .padding(.horizontal, 32)
  }
  
  private func updateNewProfile() {
    withAnimation {
      _isShowingEditPopUp = false
    }
    
    var newUpdate = CFUser.currentUserFromDb
    
    newUpdate?.photoURL = URL(string: _observerForEditPopUp.photoURL)
    newUpdate?.displayName = _observerForEditPopUp.fullName
    
    do {
      hudState = .loading()
      
      let _ = try newUpdate?.save { error, _ in
        Task {
          try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
          
          hudState = nil
          
          if error != nil {
            Toast(text: "Error: "+error!.localizedDescription).show()
          } else {
            Toast(text: "Updated.").show()
            
            withAnimation {
              _observer.photoURL = _observerForEditPopUp.photoURL
              _observer.fullName = _observerForEditPopUp.fullName
            }
          }
        }
      }
    } catch {
      Task {
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        hudState = nil
        Toast(text: "Error: "+error.localizedDescription).show()
      }
    }
  }
}

struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    ProfileView()
  }
}
