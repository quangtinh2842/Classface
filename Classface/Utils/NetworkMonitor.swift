//
//  NetworkMonitor.swift
//  Classface
//
//  Created by Soren Inis Ngo on 31/03/2026.
//

import Network
import Foundation

class NetworkMonitor: ObservableObject {
  private let monitor = NWPathMonitor()
  private let queue = DispatchQueue(label: "NetworkMonitor")
  
  @Published var isConnected = true
  @Published var isExpensive = false
  
  init() {
    monitor.pathUpdateHandler = { [weak self] path in
      print("from NetworkMonitor",path)
      
      DispatchQueue.main.async {
        self?.isConnected = path.status == .satisfied
        self?.isExpensive = path.isExpensive
      }
    }
    monitor.start(queue: queue)
  }
}
