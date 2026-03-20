//
//  ResourcesView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 16/03/2026.
//

import SwiftUI

struct ResourcesView: View {
  
  
  var body: some View {
    VStack {
      List(ResourcesStore.resources, id: \.self) { resource in
        Text(resource)
      }
    }
    .navigationTitle("Resources")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.visible, for: .navigationBar)
  }
}

struct ResourcesView_Previews: PreviewProvider {
  static var previews: some View {
    ResourcesView()
  }
}
