//
//  RollCallSessionView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 25/03/2026.
//

import SwiftUI
import HUD
import Kingfisher
import Toaster

struct RollCallSessionView: View {
  @Binding var rollCallSessions: [CFRollCallSession]
  
  var cid: String
  
  @StateObject private var _observer: RollCallSessionViewObserver
  
  var rollCallSession: CFRollCallSession?
  
  enum Field {
    case rid, sessionName
  }
  
  @FocusState private var _focusedField: Field?
  
  @State var hudState: HUDState?
  
  @State private var _selectedRollCallPhoto: CFRollCallPhoto?
  @State var isShowingDetectedStudents = false
  
  @State var isShowingAddPhoto = false
  @State private var _tmpPhotoURL = ""
  
  init(rollCallSession: CFRollCallSession? = nil, cid: String, rollCallSessions: Binding<[CFRollCallSession]>) {
    self.cid = cid
    self.rollCallSession = rollCallSession
    self._rollCallSessions = rollCallSessions
    self.__observer = StateObject(wrappedValue: RollCallSessionViewObserver(rollCallSession: rollCallSession, cid: cid))
  }
  
  var body: some View {
    VStack {
      List {
        Section {
          HStack(spacing: 0) {
            Text("RID")
              .frame(width: 150, alignment: .leading)
            TextField("Automatically", text: $_observer.rid)
              .font(.system(size: 17))
              .focused($_focusedField, equals: .rid)
              .submitLabel(.next)
              .onSubmit {
                _focusedField = .sessionName
              }
              .disabled(true)
          }
          
          HStack(spacing: 0) {
            Text("Session Name")
              .frame(width: 150, alignment: .leading)
            TextField("Session Name", text: $_observer.sessionName)
              .font(.system(size: 17))
              .focused($_focusedField, equals: .sessionName)
              .submitLabel(.done)
              .onSubmit {
                _focusedField = nil
              }
          }
        }
        
        if !_observer.rollCallPhotos.isEmpty {
          Section {
            ForEach(_observer.rollCallPhotos, id: \.photoURL!) { rollCallPhoto in
              row(rollCallPhoto: rollCallPhoto)
                .listRowInsets(EdgeInsets())
                .onTapGesture {
                  _selectedRollCallPhoto = rollCallPhoto
                  isShowingDetectedStudents = true
                }
            }
          }
        }
        
        Section {
          Button {
            isShowingAddPhoto = true
          } label: {
            Text("Add Photo")
          }
        }
      }
      .navigationTitle(rollCallSession == nil ? "Add New Session" : "Edit Session")
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
      .alert("", isPresented: $isShowingAddPhoto) {
        TextField("Photo URL", text: $_tmpPhotoURL)
        Button("Add", action: _handleAddButtonOfAlert)
        Button("Cancel", role: .cancel) {}
      } message: {
        Text("")
      }
      .sheet(item: $_selectedRollCallPhoto) { photo in
        VStack {
          List(photo.idsOfStudentsPresent ?? [], id: \.self) { sid in
            Text(sid)
          }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
      }
    }
  }
  
  func row(rollCallPhoto: CFRollCallPhoto) -> some View {
    ZStack(alignment: .bottomLeading) {
      KFImage(URL(string: rollCallPhoto.photoURL!)!)
        .placeholder {
          Image(systemName: "person.3")
            .resizable()
            .foregroundColor(.gray.opacity(0.4))
        }
        .resizable()
        .cacheOriginalImage()
        .scaledToFill()
        .frame(maxWidth: .infinity)
        .frame(height: 200)
      
      LinearGradient(
        gradient: Gradient(colors: [.black.opacity(0.8), .clear]),
        startPoint: .bottom,
        endPoint: .center
      )
      
      Text("Detected: \(rollCallPhoto.idsOfStudentsPresent?.count ?? 0) Students")
        .foregroundColor(.white)
        .padding(.leading, 16)
        .padding(.bottom, 8)
    }
  }
  
  private func _handleAddButtonOfAlert() {
    hudState = .loading()
    
    let currentClass = CFClass.getClassWith(cid: self.cid)!
    let photoURL = self._tmpPhotoURL
    self._tmpPhotoURL = ""
    
    Task {
      do {
        let students = try await currentClass.getStudentsInPhoto(photoURL: photoURL)
        let sids = students.map { $0.sid! }
        let rollCallPhoto = CFRollCallPhoto(photoURL: photoURL, idsOfStudentsPresent: sids)
        _observer.rollCallPhotos.append(rollCallPhoto)
        hudState = nil
      } catch {
        hudState = nil
        Toast(text: "Error: "+error.localizedDescription).show()
      }
    }
  }
  
  private func _handleSaveButton() {
    if _observer.rollCallPhotos.isEmpty {
      Toast(text: "Error: You need to add at least one photo.").show()
      return
    }
    
    let session = _observer.currentRollCallSession()
    hudState = .loading()
    do {
      let _ = try session.save { error, _ in
        hudState = nil
        
        if error != nil {
          Toast(text: "Error: "+error!.localizedDescription).show()
        } else {
          Toast(text: "Saved.").show()
          rollCallSessions.append(session)
          if rollCallSession == nil {
            CFRollCallSession.allRollCallSessionsRelatedToCurrentUser?.append(session)
          } else {
            CFRollCallSession.updateForGlobalArray(rollCallSession: session)
          }
        }
      }
    } catch {
      hudState = nil
      Toast(text: "Error: "+error.localizedDescription).show()
    }
  }
}

//  struct RollCallSessionView_Previews: PreviewProvider {
//    static var previews: some View {
//      RollCallSessionView()
//    }
//  }
