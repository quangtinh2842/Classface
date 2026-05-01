//
//  CFRollCallPhoto.swift
//  Classface
//
//  Created by Soren Inis Ngo on 26/03/2026.
//

import Foundation

struct CFRollCallPhoto: Codable, Identifiable {
  var id: String = UUID().uuidString
  
  var photoURL: String?
  var idsOfStudentsPresent: [String]?
}
