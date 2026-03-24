//
//  EditClassView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 22/03/2026.
//

import SwiftUI

struct EditClassView: View {
  @StateObject private var _observer = EditClassViewObserver()
  
  var cfClass: CFClass?
  
  var body: some View {
    VStack {
      
    }
    .navigationTitle(cfClass == nil ? "Add New Class" : "Edit Class")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.visible, for: .navigationBar)
  }
}

struct EditClassView_Previews: PreviewProvider {
  static var previews: some View {
    EditClassView()
  }
}
