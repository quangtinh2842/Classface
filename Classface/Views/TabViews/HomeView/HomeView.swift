//
//  HomeView.swift
//  Classface
//
//  Created by Soren Inis Ngo on 15/03/2026.
//

import SwiftUI
import Kingfisher
import Toaster

struct HomeView: View {
  @StateObject private var _observer = HomeViewObserver.shared
  
  var body: some View {
    NavigationStack {
      VStack {
        List {
          ForEach(_observer.allClasses, id: \.cid) { cfClass in
            classRow(cfClass)
              .listRowSeparator(.hidden)
              .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
          }
          .onDelete { indexSet in
            _observer.deleteOneClass(at: indexSet, completion: { error in
              if error != nil {
                Toast(text: "Error: "+error!.localizedDescription).show()
              }
            })
          }
        }
        .listStyle(.plain)
      }
      .navigationTitle("Classface")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink(destination: EditClassView()) {
            Image(systemName: "plus")
          }
        }
      }
      .onAppear {
      }
    }
  }
  
  func classRow(_ cfClass: CFClass) -> some View {
    NavigationLink(destination: EditClassView(cfClass: cfClass)) {
      ZStack(alignment: .bottomLeading) {
        KFImage(URL(string: cfClass.backgroundURL ?? ""))
          .placeholder {
            Rectangle()
              .fill(Color.gray.opacity(0.2))
              .overlay(
                Image(systemName: "book.closed.fill")
                  .foregroundColor(.gray)
              )
          }
          .resizable()
          .scaledToFill()
          .frame(height: 160)
          .frame(maxWidth: .infinity)
        
        LinearGradient(
          gradient: Gradient(colors: [.black.opacity(0.8), .clear]),
          startPoint: .bottom,
          endPoint: .center
        )
        
        VStack(alignment: .leading, spacing: 4) {
          Text(cfClass.className!)
            .font(.title2)
            .bold()
            .foregroundColor(.white)
            .lineLimit(1)
          
          if let lecturer = cfClass.lecturerName, !lecturer.isEmpty {
            HStack(spacing: 4) {
              Image(systemName: "person.fill")
                .font(.caption)
              Text(lecturer)
                .font(.subheadline)
            }
            .foregroundColor(.white.opacity(0.9))
          }
        }
        .padding(16)
      }
      .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    .buttonStyle(PlainButtonStyle())
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
