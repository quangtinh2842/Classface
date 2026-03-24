//
//  HomeView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 15/03/2026.
//

import SwiftUI

struct HomeView: View {
  @StateObject private var _observer = HomeViewObserver.shared
  
  var body: some View {
    NavigationStack {
      VStack {
        
      }
      .navigationTitle("Classface")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink(destination: EditClassView()) {
            Image(systemName: "plus")
          }
        }
      }
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
