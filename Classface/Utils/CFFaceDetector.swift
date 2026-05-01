import Vision
import UIKit
import FaceCropper

class CFFaceDetector {
  private init() {}
  
  static func detectMultipleFaces(image: UIImage, completion handler: @escaping (Error?, [CGRect]) -> Void) {
    let cgImage = image.cgImage!
    
    let request = VNDetectFaceRectanglesRequest { (request, error) in
      if error != nil {
        handler(error, [])
        return
      }
      
      let observations = request.results as! [VNFaceObservation]
      var faceBoxes = [CGRect]()
      
      for faceObservation in observations {
        let boundingBox = faceObservation.boundingBox
        faceBoxes.append(boundingBox)
      }
      
      handler(nil, faceBoxes)
    }
    
    let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try imageRequestHandler.perform([request])
      } catch {
        handler(error, [])
      }
    }
  }
  
  static func cropFacesFrom(image: UIImage, completion handler: @escaping (Error?, [UIImage]) -> Void) {
    image.face.crop { result in
      switch result {
      case .success(let faces):
        handler(nil, faces)
      case .notFound:
        handler(NotFoundError, [])
      case .failure(let error):
        handler(error, [])
      }
    }
  }
  
  static func drawFaceBoxes(on originalImage: UIImage, faceBoxes: [CGRect]) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: originalImage.size)
    
    let outputImage = renderer.image { (context) in
      originalImage.draw(at: .zero)
      
      let cgContext = context.cgContext
      cgContext.setStrokeColor(UIColor.yellow.cgColor)
      cgContext.setLineWidth(10.0)
      
      let imageWidth = originalImage.size.width
      let imageHeight = originalImage.size.height
      
      for normalizedRect in faceBoxes {
        let pixelRect = CGRect(
          x: normalizedRect.origin.x * imageWidth,
          y: (1.0 - normalizedRect.origin.y - normalizedRect.size.height) * imageHeight,
          width: normalizedRect.size.width * imageWidth,
          height: normalizedRect.size.height * imageHeight
        )
        
        cgContext.addRect(pixelRect)
        cgContext.drawPath(using: .stroke)
      }
    }
    
    return outputImage
  }
}
