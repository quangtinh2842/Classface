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
import Toaster
import KRProgressHUD

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
    
  var body: some Scene {
    WindowGroup {
      MainEntryView(user: $user)
        .onOpenURL { url in
          GIDSignIn.sharedInstance.handle(url)
        }
        .onAppear {
          if UserDefaultsHelper.wasRememberMeTicked() {
            KRProgressHUD.show()
            GIDSignIn.sharedInstance.restorePreviousSignIn { resultUser, error in
              KRProgressHUD.dismiss()
              
              if resultUser != nil || Auth.auth().currentUser != nil {
                KRProgressHUD.show()
                processAfterSignIn { error2 in
                  KRProgressHUD.dismiss()
                  
                  if error2 != nil {
                    Toast(text: "Error: "+error2!.localizedDescription).show()
                  } else {
                    self.user = CFUser.currentUserFromAuth
                  }
                }
              } else if error != nil {
                Toast(text: "Error: "+error!.localizedDescription).show()
                return
              }
            }
          } else {
            CFUser.signOutEverywhere()
          }
        }
    }
  }
}
