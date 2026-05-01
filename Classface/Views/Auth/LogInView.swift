//
//  LogInView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 12/03/2026.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth
import HUD
import Toaster

struct LogInView: View {
  @Binding var showSignUp: Bool
  
  @StateObject private var _observer = LogInViewObserver()
  
  enum Field {
    case emailAddress
    case password
  }
  
  @FocusState private var _focusedField: Field?
  
  @Binding var user: CFUser?
  
  @State var currentNonce: String?
    
  @State var hudState: HUDState?
  
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
            
            Text("Log in to your Account")
              .font(.system(size: 24, weight: .medium))
              .padding(.bottom, 4)
            Text("Welcome back, please enter your details.")
              .font(.system(size: 14, weight: .light))
              .padding(.bottom, 24)
          }
          
          Group {
            Button {
              handleSignInWithGoogleButton()
            } label: {
              HStack(spacing: 16) {
                Image("icons8-google")
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: 30, height: 30)
                  .clipped()
                Text("Continue with Google")
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
              .padding(.horizontal, 32)
              
            }
            .padding(.bottom, 16)
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
          .padding(.horizontal, 48)
          .padding(.bottom, 16)
          
          Text("Email Address")
            .font(.system(size: 14, weight: .light))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 40)
            .padding(.bottom, 4)
          
          TextField("Enter your email", text: $_observer.emailAddress)
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
            .padding(.horizontal, 32)
            .padding(.bottom, 16)
          
          Text("Password")
            .font(.system(size: 14, weight: .light))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 40)
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
            .submitLabel(.done)
            .onSubmit {
              _focusedField = nil
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
          .padding(.horizontal, 32)
          .padding(.bottom, 16)
          
          HStack {
            Button {
              _observer.rememberMe.toggle()
              UserDefaultsHelper.saveRememberMe(isTicked: _observer.rememberMe)
            } label: {
              HStack {
                Image(systemName: _observer.rememberMe ? "checkmark.square.fill" : "square.fill")
                  .font(.system(size: 20))
                  .foregroundColor(_observer.rememberMe ? Color(.tintColor) : Color(.systemGray))
                Text("Remember me")
                  .font(.system(size: 14, weight: .light))
                  .foregroundColor(Color(.label))
              }
            }
            
            Spacer()
            
            NavigationLink(destination: ForgotPassView()) {
              Text("Forgot Password?")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(.label))
            }
          }
          .padding(.horizontal, 32)
          .padding(.bottom, 16)
          
          Button {
            handleLogInButton()
          } label: {
            Text("Log in")
              .foregroundColor(Color.white)
              .padding(.vertical, 16)
              .frame(maxWidth: .infinity)
              .background(Color(.tintColor))
              .cornerRadius(8)
              .font(.system(size: 18))
          }
          .padding(.horizontal, 32)
          .padding(.bottom, 32)
          
          Group {
            HStack(spacing: 4) {
              Text("Don't have an account?")
                .font(.system(size: 14))
              Button {
                showSignUp = true
              } label: {
                Text("Sign Up")
                  .font(.system(size: 14))
                  .fontWeight(.medium)
              }
            }
            
            Spacer(minLength: 56)
          }
        }
      }
      .overlayHUD($hudState)
    }
  }
  
  func handleLogInButton() {
    if _observer.emailAddress.isEmpty {
      Toast(text: "Error: Email Address is empty.").show()
      return
    }
    
    if _observer.password.isEmpty {
      Toast(text: "Error: Password is empty.").show()
      return
    }
    
    Auth.auth().signIn(withEmail: _observer.emailAddress, password: _observer.password) { result, error in
      if error != nil {
        Toast(text: "Logging in error: "+error!.localizedDescription).show()
        return
      }
      
      hudState = .loading()
      processAfterSignIn { error2 in
        hudState = nil
        
        if error2 != nil {
          Toast(text: "Error: "+error2!.localizedDescription).show()
        } else {
          self.user = CFUser.currentUserFromAuth
        }
      }
    }
  }
  
  func handleSignInWithGoogleButton() {
    if let rootVC = getRootVC() {
      GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
        if error != nil {
          Toast(text: "Error: "+error!.localizedDescription).show()
          return
        }
        
        hudState = .loading()
        processAfterSignIn { error2 in
          hudState = nil
          
          if error2 != nil {
            Toast(text: "Error: "+error2!.localizedDescription).show()
          } else {
            self.user = CFUser.currentUserFromAuth
          }
        }
      }
    }
  }
}

//struct LogInView_Previews: PreviewProvider {
//  static var previews: some View {
//    LogInView(showSignUp: .constant(false), user: .constant(CFUser.mockUser))
//  }
//}
