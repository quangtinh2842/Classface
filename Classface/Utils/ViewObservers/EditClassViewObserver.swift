//
//  EditClassViewObserver.swift
//  Classface
//
//  Created by Soren Inis Ngo on 22/03/2026.
//

import Foundation

class EditClassViewObserver: NSObject, ObservableObject {
  @Published var students: [CFStudent] = []
}
