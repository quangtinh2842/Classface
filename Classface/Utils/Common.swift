//
//  Common.swift
//  Classface
//
//  Created by Soren Inis Ngo on 13/03/2026.
//

import UIKit
import FirebaseDatabase

func getRootVC() -> UIViewController? {
  guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let rootVC = scene.windows.first?.rootViewController else {
    return nil
  }
  
  return getvisibleVC(from: rootVC)
}

func getvisibleVC(from vc: UIViewController) -> UIViewController {
  if let nav = vc as? UINavigationController {
    return getvisibleVC(from: nav.visibleViewController!)
  }
  
  if let tab = vc as? UITabBarController {
    return getvisibleVC(from: tab.selectedViewController!)
  }
  
  if let presented = vc.presentedViewController {
    return getvisibleVC(from: presented)
  }
  
  return vc
}

typealias ObjectQueryResultHandler = (_ result: CFBase?, _ error: Error?) -> ()
typealias CollectionQueryResultHandler = (_ results: [CFBase], _ error: Error?) -> ()
typealias StatusReturnHandler = (_ status: Bool, _ error: Error?) -> ()
typealias ErrorHandler = (Error?) -> ()
typealias UpdateValueHandler = (Error?, DatabaseReference) -> ()
typealias NotificationHandler = (_ notifications: [CFNotification], _ junctions: [CFNotificationAndUser], _ error: Error?) -> ()

let NotFoundError: NSError = {
  return NSError(domain: "Not found", code: -1002, userInfo: [NSLocalizedDescriptionKey: "Result(s) not found"])
}()

enum QueryClausesEnum: String {
  case OrderedChildKey = "OrderedChildKey"
  case StartValue = "StartValue"
  case EndValue = "EndValue"
  case ExactValue = "ExactValue"
}

enum ModelValidationError: Error {
  case Valid
  case InvalidId
  case InvalidTimestamp
  case InvalidBlankAttribute
}

func sleepWith(duration seconds: UInt64) async throws {
  try await Task.sleep(nanoseconds: seconds * 1_000_000_000)
}

func processAfterSignUp(completion handler: @escaping (Error?) -> Void) {
  CFUser.syncFromCurrentUser { error in
    if error != nil {
      handler(error)
    } else {
      CFUser.currentUserFromDb = CFUser.currentUserFromAuth
      
      CFNotification.allNotificationsForCurrentUser { notifications, junctions, error2 in
        if error2 != nil {
          handler(error2)
        } else {
          CFNotification.notificationsOfCurrentUser = notifications
          CFNotificationAndUser.junctionRecordsOfCurrentUser = junctions
          handler(nil)
        }
      }
    }
  }
}

func processAfterSignIn(completion handler: @escaping (Error?) -> Void) {
  Task {
    try? await sleepWith(duration: 1)
    CFUser.find(byId: CFUser.currentUserFromAuth!.uid!) { result, error in
      if error != nil {
        handler(error)
      } else {
        let syncedUser = result as! CFUser
        CFUser.currentUserFromDb = syncedUser
        
        CFNotification.allNotificationsForCurrentUser { notifications, junctions, error2 in
          if error2 != nil {
            handler(error2)
          } else {
            CFNotification.notificationsOfCurrentUser = notifications
            CFNotificationAndUser.junctionRecordsOfCurrentUser = junctions
            handler(nil)
          }
        }
      }
    }
  }
}
