//
//  LogInViewObserver.swift
//  Classface
//
//  Created by Soren Inis Ngo on 12/03/2026.
//

import SwiftUI

class LogInViewObserver: NSObject, ObservableObject {
  @Published var emailAddress: String = ""
  @Published var password: String = ""
  @Published var rememberMe: Bool = UserDefaultsHelper.wasRememberMeTicked()
  @Published var isPasswordVisible: Bool = false
}
