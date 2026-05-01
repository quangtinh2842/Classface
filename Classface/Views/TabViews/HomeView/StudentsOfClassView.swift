//
//  StudentsOfClassView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 24/03/2026.
//

import SwiftUI
import Kingfisher

struct StudentsOfClassView: View {
  @ObservedObject var observer: EditClassViewObserver
  
  var body: some View {
    VStack {
      List(StudentsViewObserver.shared.allStudents, id: \.sid) { student in
        studentRow(student)
      }
    }
  }
  
  func studentRow(_ student: CFStudent) -> some View {
    let isAdded = wasStudentAdded(student: student)
    
    return HStack(spacing: 16) {
      Image(systemName: isAdded ? "checkmark.circle.fill" : "circle")
        .foregroundColor(isAdded ? Color(.tintColor) : .gray)
        .font(.system(size: 22))
        .onTapGesture {
          toggleStudentSelection(student)
        }
      
      KFImage(URL(string: student.photoURL!))
        .placeholder {
          Image(systemName: "person.crop.circle.fill")
            .resizable()
            .foregroundColor(.gray.opacity(0.4))
        }
        .resizable()
        .scaledToFill()
        .frame(width: 55, height: 55)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 10))
      
      VStack(alignment: .leading, spacing: 4) {
        Text(student.name!)
          .font(.system(size: 16, weight: .semibold))
        Text(student.sid!)
          .font(.subheadline)
          .foregroundColor(.secondary)
          .lineLimit(1)
      }
      
      Spacer()
    }
    .contentShape(Rectangle())
    .onTapGesture {
      toggleStudentSelection(student)
    }
    .padding(.vertical, 8)
  }
  
  func toggleStudentSelection(_ student: CFStudent) {
    if let index = observer.students.firstIndex(where: { $0.sid == student.sid }) {
      observer.students.remove(at: index)
    } else {
      observer.students.append(student)
    }
  }
  
  func wasStudentAdded(student: CFStudent) -> Bool {
    return observer.students.contains(where: { $0.sid == student.sid })
  }
}

//struct StudentsOfClassView_Previews: PreviewProvider {
//  static var previews: some View {
//    StudentsOfClassView()
//  }
//}
