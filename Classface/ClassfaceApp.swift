//
//  ClassfaceApp.swift
//  Classface
//
//  Created by Soren Inis Ngo on 12/03/2026.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import FirebaseAuth
import AlertToast

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct ClassfaceApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
  @State var user: CFUser?
  
  @State var showToast: Bool = false
  @State var toast: AlertToast = AlertToast(displayMode: .hud, type: .loading)
  
  var body: some Scene {
    WindowGroup {
      MainEntryView(user: $user)
        .onOpenURL { url in
          GIDSignIn.sharedInstance.handle(url)
        }
        .onAppear {
          if UserDefaultsHelper.wasRememberMeTicked() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { resultUser, error in
              if error != nil {
                return
              }
              
              if resultUser != nil {
                showToast = true
                processAfterSignIn { error2 in
                  showToast = false
                  
                  if error2 != nil {
                  } else {
                    self.user = CFUser.currentUserFromAuth
                  }
                }
              } else if Auth.auth().currentUser != nil {
                showToast = true
                processAfterSignIn { error2 in
                  showToast = false
                  
                  if error2 != nil {
                  } else {
                    self.user = CFUser.currentUserFromAuth
                  }
                }
              }
            }
          } else {
            CFUser.signOutEverywhere()
          }
        }
        .toast(isPresenting: $showToast, alert: {
          return toast
        })
    }
  }
}
