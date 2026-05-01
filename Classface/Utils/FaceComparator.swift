//
//  FaceComparator.swift
//  Classface
//
//  Created by Soren Inis Ngo on 28/03/2026.
//

import Foundation

class FaceComparator {
  static let shared = FaceComparator()
  
  private let fNet = FaceNet()
  private let fDetector = FaceDetector.shared
  
  private init() {
    fNet.load()
  }
  
  private func extractOneFaceIn(image: UIImage) -> CIImage {
    return fDetector.extractFaces(frame: CIImage(image: image)!).first!
  }
  
  func vectorOf(face: CIImage, completion handler: @escaping ([Double]) -> Void) {
//    let oneFace = CIImage(image: face)! // extractOneFaceIn(image: face)
    let vector = fNet.run(image: face)
    handler(vector)
  }
  
  func vectorOf(face: CIImage) async -> [Double] {
//    let oneFace = CIImage(image: face)! // extractOneFaceIn(image: face)
    let vector = fNet.run(image: face)
    return vector
  }
  
  func compare2Faces(v1: [Double], v2: [Double]) -> Bool {
    if self.l2distance(v1, v2) >= 1 {
      return false
    } else {
      return true
    }
  }
  
  func compare2Faces(f1: CIImage, f2: CIImage, completion handler: @escaping (Bool) -> Void) {
    vectorOf(face: f1) { [weak self] v1 in
      self!.vectorOf(face: f2) { [weak self] v2 in
        if self!.l2distance(v1, v2) >= 1 {
          handler(false)
        } else {
          handler(true)
        }
      }
    }
  }
  
  private func l2distance(_ feat1: [Double], _ feat2: [Double]) -> Double {
    return sqrt(zip(feat1, feat2).map { f1, f2 in pow(f2 - f1, 2) }.reduce(0, +))
  }
}
