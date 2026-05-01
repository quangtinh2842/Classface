//
//  SignUpViewObserver.swift
//  Classface
//
//  Created by Soren Inis Ngo on 13/03/2026.
//

import SwiftUI

class SignUpViewObserver: NSObject, ObservableObject {
  @Published var fullName: String = ""
  @Published var emailAddress: String = ""
  @Published var password: String = ""
  @Published var isPasswordVisible: Bool = false
  @Published var confirmPassword: String = ""
  @Published var isConfirmPasswordVisible: Bool = false
  @Published var agreeToTOS: Bool = false
}
