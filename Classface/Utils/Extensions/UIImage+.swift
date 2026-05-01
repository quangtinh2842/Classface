//
//  UIImage+.swift
//  Classface
//
//  Created by Soren Inis Ngo on 27/04/2026.
//

import Foundation

extension UIImage {
  func resizeImage(newWidth: CGFloat, newHeight: CGFloat) -> UIImage? {
    UIGraphicsBeginImageContext(CGSize(width: floor(newWidth),
                                       height: floor(newHeight)))
    self.draw(in: CGRect(x: 0,
                         y: 0,
                         width: newWidth,
                         height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
  }
}
