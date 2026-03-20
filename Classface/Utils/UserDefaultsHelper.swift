//
//  UserDefaultsHelper.swift
//  Classface
//
//  Created by Soren Inis Ngo on 15/03/2026.
//

import Foundation

struct UserDefaultsHelper {
  private static let _rememberMeKey = "remember-me"
  
  static func saveRememberMe(isTicked: Bool) {
    UserDefaults.standard.set(isTicked, forKey: _rememberMeKey)
  }
  
  static func wasRememberMeTicked() -> Bool {
    let rememberMe = UserDefaults.standard.object(forKey: _rememberMeKey) as? Bool
    return rememberMe ?? true
  }
}
