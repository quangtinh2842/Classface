//
//  CIImage+.swift
//  Classface
//
//  Created by Soren Inis Ngo on 27/04/2026.
//

import Foundation

extension CIImage {
  func resizeImage(newWidth: CGFloat, newHeight: CGFloat) -> UIImage? {
    return UIImage(ciImage: self).resizeImage(newWidth: newWidth,
                                              newHeight: newHeight)
  }
}
