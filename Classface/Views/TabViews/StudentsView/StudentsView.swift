//
//  StudentsView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 22/03/2026.
//

import SwiftUI
import Kingfisher
import AlertToast

struct StudentsView: View {
  @StateObject private var _observer = StudentsViewObserver.shared
  
  @State var showToast = false
  @State var toast: AlertToast = AlertToast(displayMode: .alert, type: .regular)
  
  var body: some View {
    NavigationStack {
      VStack {
        List {
          ForEach(_observer.allStudents, id: \.sid) { student in
            studentRow(student)
          }
          .onDelete { indexSet in
            _observer.deleteOneStudent(at: indexSet, completion: { error in
              if error != nil {
                toast = AlertToast(displayMode: .banner(.pop), type: .error(.red), title: "Error", subTitle: error!.localizedDescription)
                showToast = true
              }
            })
          }
        }
      }
      .navigationTitle("Students")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink(destination: EditStudentView()) {
            Image(systemName: "plus")
          }
        }
      }
      .toast(isPresenting: $showToast, alert: {
        return toast
      })
    }
  }
  
  func studentRow(_ student: CFStudent) -> some View {
    NavigationLink(destination: EditStudentView(student: student)) {
      HStack(spacing: 16) {
        KFImage(URL(string: student.photoURL!)!)
          .placeholder {
            Image(systemName: "person.crop.circle.fill")
              .resizable()
              .foregroundColor(.gray.opacity(0.4))
          }
          .resizable()
          .cacheOriginalImage()
          .scaledToFill()
          .frame(width: 55, height: 55)
          .clipShape(Circle())
          .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 10))
        
        VStack(alignment: .leading, spacing: 4) {
          Text(student.name!)
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.primary)
            .lineLimit(1)
          
          Text(student.sid!)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .lineLimit(1)
        }
        
        Spacer()
      }
      .padding(.vertical, 8)
      .padding(.horizontal, 4)
    }
  }
}

struct StudentsView_Previews: PreviewProvider {
  static var previews: some View {
    StudentsView()
  }
}
