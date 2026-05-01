//
//  RollCallSessionsView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 25/03/2026.
//

import SwiftUI

struct RollCallSessionsView: View {
  var cid: String
  
  @State var rollCallSessions: [CFRollCallSession] = []
  
  var body: some View {
    VStack {
      List(rollCallSessions, id: \.rid!) { session in
        row(rollCallSession: session)
      }
    }
    .navigationTitle("Roll Call Sessions")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        NavigationLink {
          RollCallSessionView(cid: self.cid, rollCallSessions: $rollCallSessions)
        } label: {
          Image(systemName: "plus")
        }
      }
    }
    .onAppear {
      self.rollCallSessions = CFRollCallSession.rollCallSessionsOfClass(cid: self.cid)
    }
  }
  
  func row(rollCallSession: CFRollCallSession) -> some View {
    NavigationLink(destination: RollCallSessionView(rollCallSession: rollCallSession, cid: cid, rollCallSessions: $rollCallSessions)) {
      VStack(alignment: .leading) {
        Text(rollCallSession.sessionName!)
          .font(.title)
        Text("Attendance Result: "+rollCallSession.attendanceResult())
          .font(.caption)
      }
    }
  }
}

//struct RollCallSessionsView_Previews: PreviewProvider {
//  static var previews: some View {
//    RollCallSessionsView()
//  }
//}
