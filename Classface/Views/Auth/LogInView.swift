//
//  LogInView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 12/03/2026.
//

import SwiftUI
import GoogleSignIn
import AlertToast
import FirebaseAuth
import CryptoKit
import _AuthenticationServices_SwiftUI
import HUD

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
  
  @State var showToast = false
  @State var toast: AlertToast = AlertToast(displayMode: .alert, type: .regular)
  
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
            
//            Button {
//              
//            } label: {
//              HStack(spacing: 16) {
//                Image("icons8-apple")
//                  .resizable()
//                  .aspectRatio(contentMode: .fill)
//                  .frame(width: 30, height: 30)
//                  .clipped()
//                Text("Continue with Apple")
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
//              .padding(.horizontal, 32)
//            }
//            .padding(.bottom, 16)
            
//            SignInWithAppleButton(
//              onRequest: { request in
//                let nonce = randomNonceString()
//                currentNonce = nonce
//                request.requestedScopes = [.fullName, .email]
//                request.nonce = sha256("nonce")
//              },
//              onCompletion: { result in
//                switch result {
//                case .success(let authResults):
//                  switch authResults.credential {
//                  case let appleIDCredential as ASAuthorizationAppleIDCredential:
//
//                    guard let nonce = currentNonce else {
//                      fatalError("Invalid state: A login callback was received, but no login request was sent.")
//                    }
//                    guard let appleIDToken = appleIDCredential.identityToken else {
//                      fatalError("Invalid state: A login callback was received, but no login request was sent.")
//                    }
//                    guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//                      print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
//                      return
//                    }
//
//                    let credential = OAuthProvider.credential(withProviderID: "apple.com",idToken: idTokenString,rawNonce: nonce)
//                    Auth.auth().signIn(with: credential) { (authResult, error) in
//                      if (error != nil) {
//                        // Error. If error.code == .MissingOrInvalidNonce, make sure
//                        // you're sending the SHA256-hashed nonce as a hex string with
//                        // your request to Apple.
//                        print(error?.localizedDescription as Any)
//                        return
//                      }
//                      print("signed in")
//                    }
//
//                    print("\(String(describing: Auth.auth().currentUser?.uid))")
//                  default:
//                    break
//
//                  }
//                default:
//                  break
//                }
//              }
//            )
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
      .toast(isPresenting: $showToast, alert: {
        return toast
      })
      .overlayHUD($hudState)
    }
  }
  
  private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    var randomBytes = [UInt8](repeating: 0, count: length)
    let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    if errorCode != errSecSuccess {
      fatalError(
        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
      )
    }
    
    let charset: [Character] =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    
    let nonce = randomBytes.map { byte in
      // Pick a random character from the set, wrapping around if needed.
      charset[Int(byte) % charset.count]
    }
    
    return String(nonce)
  }
  
  @available(iOS 13, *)
  private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
      String(format: "%02x", $0)
    }.joined()
    
    return hashString
  }
  
  func handleLogInButton() {
    if _observer.emailAddress.isEmpty {
      toast = AlertToast(displayMode: .banner(.pop), type: .error(.red), title: "Error", subTitle: "Email Address is empty.")
      showToast = true
      return
    }
    
    if _observer.password.isEmpty {
      toast = AlertToast(displayMode: .banner(.pop), type: .error(.red), title: "Error", subTitle: "Password is empty.")
      showToast = true
      return
    }
    
    Auth.auth().signIn(withEmail: _observer.emailAddress, password: _observer.password) { result, error in
      if error != nil {
        toast = AlertToast(displayMode: .banner(.pop), type: .error(.red), title: "Error", subTitle: "Logging in error: "+error!.localizedDescription)
        showToast = true
        return
      }
      
      hudState = .loading()
      processAfterSignIn { error2 in
        hudState = nil
        
        if error2 != nil {
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
          return
        }
        
        hudState = .loading()
        processAfterSignIn { error2 in
          hudState = nil
          
          if error2 != nil {
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
