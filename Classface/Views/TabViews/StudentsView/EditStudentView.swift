//
//  EditStudentView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 22/03/2026.
//

import SwiftUI
import HUD
import Toaster

struct EditStudentView: View {
  @StateObject private var _observer: EditStudentViewObserver
  var student: CFStudent?
  
  enum Field {
    case sid, photoURL, name
  }
  
  @FocusState private var _focusedField: Field?
  
  @State var hudState: HUDState?
  
  init(student: CFStudent? = nil) {
    self.student = student
    self.__observer = StateObject(wrappedValue: EditStudentViewObserver(student: student))
  }
  
  var body: some View {
    VStack {
      List {
        Section {
          HStack(spacing: 0) {
            Text("SID")
              .frame(width: 100, alignment: .leading)
            TextField("Automatically", text: $_observer.sid)
              .font(.system(size: 17))
              .focused($_focusedField, equals: .sid)
              .submitLabel(.next)
              .onSubmit {
                _focusedField = .photoURL
              }
              .disabled(true)
          }
          
          HStack(spacing: 0) {
            Text("Photo URL")
              .frame(width: 100, alignment: .leading)
            TextField("Photo URL", text: $_observer.photoURL)
              .font(.system(size: 17))
              .focused($_focusedField, equals: .photoURL)
              .submitLabel(.next)
              .onSubmit {
                _focusedField = .name
              }
          }
          
          HStack(spacing: 0) {
            Text("Name")
              .frame(width: 100, alignment: .leading)
            TextField("Name", text: $_observer.name)
              .font(.system(size: 17))
              .focused($_focusedField, equals: .name)
              .submitLabel(.next)
              .onSubmit {
                _focusedField = nil
              }
          }
        }
      }
    }
    .navigationTitle(student == nil ? "Add New Student" : "Edit Student")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          _handleSaveButton()
        } label: {
          Text("Save")
        }
      }
    }
    .overlayHUD($hudState)
  }
  
  private func _handleSaveButton() {
    hudState = .loading()
    do {
      let _ = try _observer.editingStudent().save { error, _ in
        hudState = nil
        
        if error != nil {
          Toast(text: "Error: "+error!.localizedDescription).show()
        } else {
          Toast(text: "Saved.").show()
          StudentsViewObserver.shared.updateLocal(student: _observer.editingStudent())
        }
      }
    } catch {
      hudState = nil
      Toast(text: "Error: "+error.localizedDescription).show()
    }
  }
}

struct EditStudentView_Previews: PreviewProvider {
  static var previews: some View {
    EditStudentView()
  }
}
