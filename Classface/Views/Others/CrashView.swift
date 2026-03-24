//
//  CrashView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 19/03/2026.
//

import SwiftUI

struct CrashView: View {
  var title: String = "Something went wrong"
  var subTitle: String = "Please close the app and open again."
  var iconName: String = "exclamationmark.triangle.fill"
  
  var body: some View {
    VStack(spacing: 24) {
      Image(systemName: iconName)
        .resizable()
        .scaledToFit()
        .frame(width: 80, height: 80)
        .foregroundColor(.red)
        .padding()
        .background(Circle().fill(Color.red.opacity(0.1)))
      
      VStack(spacing: 8) {
        Text(title)
          .font(.title2)
          .fontWeight(.bold)
          .foregroundColor(Color(.label))
          .multilineTextAlignment(.center)
        
        Text(subTitle)
          .font(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
      }
    }
  }
}

struct CrashView_Previews: PreviewProvider {
  static var previews: some View {
    CrashView()
  }
}
