//
//  SignUpView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 13/03/2026.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth
import Toaster

struct SignUpView: View {
  @Binding var showSignUp: Bool
  
  @StateObject private var _observer = SignUpViewObserver()
  
  enum Field {
    case fullName
    case emailAddress
    case password
    case confirmPassword
  }
  
  @FocusState private var _focusedField: Field?
  
  @Binding var user: CFUser?
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 0) {
          Group {
            Spacer(minLength: 56)
            Image("logo")
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: 130, height: 130)
              .clipped()
              .cornerRadius(8)
              .padding(.bottom, 24)
            
            Text("Create an Account")
              .font(.system(size: 24, weight: .medium))
              .padding(.bottom, 4)
            Text("Sign up now to get started with an account.")
              .font(.system(size: 14, weight: .light))
              .padding(.bottom, 24)
          }
          
          Group {
            Button {
              self.handleSignUpWithGoogleButton()
            } label: {
              HStack(spacing: 16) {
                Image("icons8-google")
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: 30, height: 30)
                  .clipped()
                Text("Sign up with Google")
                  .foregroundColor(Color(.label))
              }
              .frame(maxWidth: .infinity)
              .padding(.vertical, 14)
              .background(Color(.secondarySystemBackground))
              .cornerRadius(8)
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(Color(.systemGray), lineWidth: 1)
              )
              
            }
            .padding(.bottom, 16)
            
//            Button {
//              
//            } label: {
//              HStack(spacing: 16) {
//                Image("icons8-apple")
//                  .resizable()
//                  .aspectRatio(contentMode: .fill)
//                  .frame(width: 30, height: 30)
//                  .clipped()
//                Text("Sign up with Apple")
//                  .foregroundColor(Color(.label))
//              }
//              .frame(maxWidth: .infinity)
//              .padding(.vertical, 14)
//              .background(Color(.secondarySystemBackground))
//              .cornerRadius(8)
//              .overlay(
//                RoundedRectangle(cornerRadius: 8)
//                  .stroke(Color(.systemGray), lineWidth: 1)
//              )
//            }
//            .padding(.bottom, 16)
          }
          
          HStack {
            Divider()
              .frame(height: 1)
              .frame(maxWidth: .infinity)
              .background(Color(.systemGray))
            
            Text("OR")
              .font(.subheadline)
              .foregroundColor(Color(.secondaryLabel))
              .padding(.horizontal, 8)
            
            Divider()
              .frame(height: 1)
              .frame(maxWidth: .infinity)
              .background(Color(.systemGray))
          }
          .padding(.horizontal, 16)
          .padding(.bottom, 16)
          
          Group {
            Group {
              HStack(spacing: 0) {
                Text("Full Name")
                  .font(.system(size: 14, weight: .light))
                  .padding(.leading, 8)
                Text("*")
                  .font(.system(size: 14, weight: .light))
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .foregroundColor(Color(.red))
              }
              .padding(.bottom, 4)
              
              TextField("Enter your full name", text: $_observer.fullName)
                .focused($_focusedField, equals: .fullName)
                .submitLabel(.next)
                .onSubmit {
                  _focusedField = .emailAddress
                }
                .padding()
                .background(
                  RoundedRectangle(cornerRadius: 8)
                    .fill(Color.clear)
                )
                .overlay(
                  RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray), lineWidth: 1)
                )
                .foregroundColor(Color(.label))
                .padding(.bottom, 16)
            }
            
            Group {
              HStack(spacing: 0) {
                Text("Email Address")
                  .font(.system(size: 14, weight: .light))
                  .padding(.leading, 8)
                Text("*")
                  .font(.system(size: 14, weight: .light))
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .foregroundColor(Color(.red))
              }
              .padding(.bottom, 4)
              
              TextField("Enter your email address", text: $_observer.emailAddress)
                .focused($_focusedField, equals: .emailAddress)
                .submitLabel(.next)
                .onSubmit {
                  _focusedField = .password
                }
                .padding()
                .background(
                  RoundedRectangle(cornerRadius: 8)
                    .fill(Color.clear)
                )
                .overlay(
                  RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray), lineWidth: 1)
                )
                .foregroundColor(Color(.label))
                .padding(.bottom, 16)
            }
            
            Group {
              HStack(spacing: 0) {
                Text("Password")
                  .font(.system(size: 14, weight: .light))
                  .padding(.leading, 8)
                Text("*")
                  .font(.system(size: 14, weight: .light))
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .foregroundColor(Color(.red))
              }
              .padding(.bottom, 4)
              
              HStack {
                Group {
                  if _observer.isPasswordVisible {
                    TextField("Enter your password", text: $_observer.password)
                  } else {
                    SecureField("Enter your password", text: $_observer.password)
                  }
                }
                .focused($_focusedField, equals: .password)
                .submitLabel(.next)
                .onSubmit {
                  _focusedField = .confirmPassword
                }
                .foregroundColor(Color(.label))
                
                Button {
                  _observer.isPasswordVisible.toggle()
                } label: {
                  Image(systemName: _observer.isPasswordVisible ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
                }
              }
              .padding()
              .background(RoundedRectangle(cornerRadius: 8).fill(Color.clear))
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(Color(.systemGray), lineWidth: 1)
              )
              .padding(.bottom, 16)
            }
            
            Group {
              HStack(spacing: 0) {
                Text("Confirm Password")
                  .font(.system(size: 14, weight: .light))
                  .padding(.leading, 8)
                Text("*")
                  .font(.system(size: 14, weight: .light))
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .foregroundColor(Color(.red))
              }
              .padding(.bottom, 4)
              
              HStack {
                Group {
                  if _observer.isConfirmPasswordVisible {
                    TextField("Confirm your password", text: $_observer.confirmPassword)
                  } else {
                    SecureField("Confirm your password", text: $_observer.confirmPassword)
                  }
                }
                .focused($_focusedField, equals: .confirmPassword)
                .submitLabel(.done)
                .onSubmit {
                  _focusedField = nil
                }
                .foregroundColor(Color(.label))
                
                Button {
                  _observer.isConfirmPasswordVisible.toggle()
                } label: {
                  Image(systemName: _observer.isConfirmPasswordVisible ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
                }
              }
              .padding()
              .background(RoundedRectangle(cornerRadius: 8).fill(Color.clear))
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(Color(.systemGray), lineWidth: 1)
              )
              .padding(.bottom, 16)
            }
            
            HStack(spacing: 0) {
              Button {
                _observer.agreeToTOS.toggle()
              } label: {
                HStack {
                  Image(systemName: _observer.agreeToTOS ? "checkmark.square.fill" : "square.fill")
                    .font(.system(size: 20))
                    .foregroundColor(_observer.agreeToTOS ? Color(.tintColor) : Color(.systemGray))
                }
              }
              .padding(.trailing, 8)
              
              Text("I agree to the")
                .font(.system(size: 14, weight: .light))
                .foregroundColor(Color(.label))
                .padding(.trailing, 4)
              
              NavigationLink(destination: TOSView()) {
                Text("Terms of Service")
                  .font(.system(size: 14))
                  .foregroundColor(Color(.tintColor))
                  .underline()
              }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 16)
            
            Button {
              handleGetStartedButton()
            } label: {
              Text("Get Started")
                .foregroundColor(Color.white)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Color(.tintColor))
                .cornerRadius(8)
                .font(.system(size: 18))
            }
            .padding(.bottom, 32)
            
            Group {
              HStack(spacing: 4) {
                Text("Already have an account?")
                  .font(.system(size: 14))
                Button {
                  showSignUp = false
                } label: {
                  Text("Log in")
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                }
              }
              
              Spacer(minLength: 56)
            }
          }
        }
        .padding(.horizontal, 32)
      }
    }
  }
  
  func handleGetStartedButton() {
    if _observer.fullName.isEmpty {
      Toast(text: "Error: Full Name is empty.").show()
      return
    }
    
    if _observer.emailAddress.isEmpty {
      Toast(text: "Error: Email Address is empty.").show()
      return
    }
    
    if _observer.password.isEmpty {
      Toast(text: "Error: Password is empty.").show()
      return
    }
    
    if _observer.confirmPassword.isEmpty {
      Toast(text: "Error: Confirm Password is empty.").show()
      return
    }
    
    if _observer.password != _observer.confirmPassword {
      Toast(text: "Error: Password is different from Confirm Password.").show()
      return
    }
    
    if _observer.agreeToTOS == false {
      Toast(text: "Error: You need to agree to the Terms of Service first.").show()
      return
    }
    
    Auth.auth().createUser(withEmail: _observer.emailAddress, password: _observer.password) { authResult, error in
      if error != nil {
        Toast(text: "Account creation error: "+error!.localizedDescription).show()
        return
      }
      
      let changeRequest = authResult?.user.createProfileChangeRequest()
      changeRequest?.displayName = _observer.fullName
      
      changeRequest?.commitChanges { error2 in
        if error2 != nil {
          Task {
            Toast(text: "Display name updating error: "+error2!.localizedDescription).show()
            
            try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
            
            processAfterSignUp { error3 in
              if error3 != nil {
                Toast(text: "Error: "+error3!.localizedDescription).show()
              } else {
                self.user = CFUser.currentUserFromAuth
              }
            }
          }
        } else {
          processAfterSignUp { error3 in
            if error3 != nil {
              Toast(text: "Error: "+error3!.localizedDescription).show()
            } else {
              self.user = CFUser.currentUserFromAuth
            }
          }
        }
      }
    }
  }
  
  func handleSignUpWithGoogleButton() {
    if _observer.agreeToTOS == false {
      Toast(text: "Error: You need to agree to the ToS first.").show()
      return
    }
    
    if let rootVC = getRootVC() {
      GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
        processAfterSignUp { error in
          if error != nil {
            Toast(text: "Error: "+error!.localizedDescription).show()
          } else {
            self.user = CFUser.currentUserFromAuth
          }
        }
      }
    }
  }
}

//struct SignUpView_Previews: PreviewProvider {
//  static var previews: some View {
//    SignUpView(showSignUp: .constant(true), user: .constant(CFUser.mockUser))
//  }
//}
