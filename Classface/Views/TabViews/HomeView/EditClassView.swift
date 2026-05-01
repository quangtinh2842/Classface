//
//  EditClassView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 22/03/2026.
//

import SwiftUI
import HUD
import Toaster

struct EditClassView: View {
  @StateObject private var _observer: EditClassViewObserver
  
  var cfClass: CFClass?
  
  enum Field {
    case cid, className, rollCallerId, backgroundURL, lecturerName
  }
  
  @FocusState private var _focusedField: Field?
  
  @State var hudState: HUDState?
  
  @State var isShowingStudentsOfClassView = false
  
  init(cfClass: CFClass? = nil) {
    self.cfClass = cfClass
    self.__observer = StateObject(wrappedValue: EditClassViewObserver(cfClass: cfClass))
  }
  
  var body: some View {
    VStack {
      List {
        Section {
          HStack(spacing: 0) {
            Text("CID")
              .frame(width: 150, alignment: .leading)
            TextField("Automatically", text: $_observer.cid)
              .font(.system(size: 17))
              .focused($_focusedField, equals: .cid)
              .submitLabel(.next)
              .onSubmit {
                _focusedField = .className
              }
              .disabled(true)
          }
          
          HStack(spacing: 0) {
            Text("Class Name")
              .frame(width: 150, alignment: .leading)
            TextField("Class Name", text: $_observer.className)
              .font(.system(size: 17))
              .focused($_focusedField, equals: .className)
              .submitLabel(.next)
              .onSubmit {
                _focusedField = .backgroundURL
              }
          }
          
          HStack(spacing: 0) {
            Text("Background URL")
              .frame(width: 150, alignment: .leading)
            TextField("Background URL", text: $_observer.backgroundURL)
              .font(.system(size: 17))
              .focused($_focusedField, equals: .backgroundURL)
              .submitLabel(.next)
              .onSubmit {
                _focusedField = .lecturerName
              }
          }
          
          HStack(spacing: 0) {
            Text("Lecturer Name")
              .frame(width: 150, alignment: .leading)
            TextField("Lecturer Name", text: $_observer.lecturerName)
              .font(.system(size: 17))
              .focused($_focusedField, equals: .lecturerName)
              .submitLabel(.done)
              .onSubmit {
                _focusedField = nil
              }
          }
        }
        
        Section {
          HStack {
            Text("Number of Students")
            Spacer()
            Text(String(_observer.students.count))
          }
          
          Button {
            isShowingStudentsOfClassView = true
          } label: {
            Text("Add Student")
          }
        }
        .disabled(cfClass == nil ? true : false)
        
        Section {
          NavigationLink {
            RollCallSessionsView(cid: _observer.cid)
          } label: {
            Text("Roll Call Sessions")
          }
        }
        .disabled(cfClass == nil ? true : false)
      }
    }
    .navigationTitle(cfClass == nil ? "Add New Class" : "Edit Class")
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
    .sheet(isPresented: $isShowingStudentsOfClassView) {
      StudentsOfClassView(observer: self._observer)
    }
  }
  
  private func _handleSaveButton() {
    hudState = .loading()
    do {
      let _ = try _observer.editingClass().save { error, _ in
        hudState = nil
        
        if error != nil {
          Toast(text: "Error: "+error!.localizedDescription).show()
        } else {
          _saveJunctions { error2 in
            if error2 != nil {
              Toast(text: "Error: "+error2!.localizedDescription).show()
            } else {
              CFClassAndStudent.fetchAllJunctionsForClasses(classIds: HomeViewObserver.shared.allClasses.map { $0.cid! }) { error3, allJunctionsOfCurrentUser in
                if error3 != nil {
                  Toast(text: "Error: "+error3!.localizedDescription).show()
                } else {
                  CFClassAndStudent.allJunctionsOfCurrentUser = allJunctionsOfCurrentUser
                  
                  _deleteRemovedStudents { error4 in
                    if error4 != nil {
                      Toast(text: "Error: "+error4!.localizedDescription).show()
                    } else {
                      Toast(text: "Saved.").show()
                      HomeViewObserver.shared.updateLocal(cfClass: _observer.editingClass())
                      _observer.studentsAfterSaving = _observer.students
                    }
                  }
                }
              }
            }
          }
        }
      }
    } catch {
      hudState = nil
      Toast(text: "Error: "+error.localizedDescription).show()
    }
  }
  
  private func _saveJunctions(completion handler: @escaping (Error?) -> Void) {
    let group = DispatchGroup()
    var firstError: Error?
    
    for student in _observer.students {
      guard firstError == nil else { break }
      
      group.enter()
      
      CFClassAndStudent.saveWith(cid: _observer.cid, sid: student.sid!) { error in
        if let error = error, firstError == nil {
          firstError = error
        }
        
        group.leave()
      }
    }
    
    group.notify(queue: .main) {
      handler(firstError)
    }
  }
  
  private func _deleteRemovedStudents(completion handler: @escaping (Error?) -> Void) {
    var removedStudents = [CFStudent]()
    
    for oldStudent in _observer.studentsAfterSaving {
      if !_observer.students.contains(where: { $0.sid == oldStudent.sid }) {
        removedStudents.append(oldStudent)
      }
    }
    
    let group = DispatchGroup()
    var firstError: Error?
    
    for student in removedStudents {
      guard firstError == nil else { break }
      
      group.enter()
      
      CFClassAndStudent.deleteWithId(_observer.cid+"_"+student.sid!) { error in
        if let error = error, firstError == nil {
          firstError = error
        }
        
        group.leave()
      }
    }
    
    group.notify(queue: .main) {
      handler(firstError)
    }
  }
}

//struct EditClassView_Previews: PreviewProvider {
//  static var previews: some View {
//    EditClassView()
//  }
//}
