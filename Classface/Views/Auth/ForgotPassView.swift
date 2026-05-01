//
//  ForgotPassView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 16/03/2026.
//

import SwiftUI
import FirebaseAuth
import Toaster

struct ForgotPassView: View {
  @State var emailAddress: String = ""
  
  enum Field {
    case emailAddress
  }
  
  @FocusState private var _focusedField: Field?
  
  var body: some View {
    VStack(spacing: 0) {
      TextField("Enter your email", text: $emailAddress)
        .submitLabel(.done)
        .onSubmit {
          _focusedField = nil
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
        .padding(.top, 32)
      
      Button {
        self.handleSendPasswordResetButton()
      } label: {
        Text("Send Password Reset")
          .foregroundColor(Color.white)
          .padding(.vertical, 16)
          .frame(maxWidth: .infinity)
          .background(Color(.tintColor))
          .cornerRadius(8)
          .font(.system(size: 18))
      }
      
      Spacer()
    }
    .padding(.horizontal, 32)
    .navigationTitle("Forgot Password")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.visible, for: .navigationBar)
  }
  
  func handleSendPasswordResetButton() {
    Auth.auth().sendPasswordReset(withEmail: self.emailAddress) { error in
      if error != nil {
        Toast(text: "Error: "+error!.localizedDescription).show()
      } else {
        Toast(text: "Sent. Please, check your Mailbox.").show()
      }
    }
  }
}

struct ForgotPassView_Previews: PreviewProvider {
  static var previews: some View {
    ForgotPassView()
  }
}
