//
//  Common.swift
//  Classface
//
//  Created by Soren Inis Ngo on 13/03/2026.
//

import UIKit
import FirebaseDatabase
import Vision

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
      return
    } else {
      CFUser.currentUserFromDb = CFUser.currentUserFromAuth
      
      CFNotification.allNotificationsForCurrentUser { notifications, junctions, error2 in
        if let error2 = error2 as? NSError, error2.domain != NotFoundError.domain {
          handler(error2)
        } else {
          CFNotification.notificationsOfCurrentUser = notifications
          CFNotificationAndUser.junctionRecordsOfCurrentUser = junctions
          
          MainTabViewObserver.shared.notifications = CFNotification.notificationsOfCurrentUser ?? []
          MainTabViewObserver.shared.junctions = CFNotificationAndUser.junctionRecordsOfCurrentUser ?? []
          
          StudentsViewObserver.shared.allStudents = []
          HomeViewObserver.shared.allClasses = []
          CFRollCallSession.allRollCallSessionsRelatedToCurrentUser = []
          CFClassAndStudent.allJunctionsOfCurrentUser = []
          
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
        return
      } else {
        let syncedUser = result as! CFUser
        CFUser.currentUserFromDb = syncedUser
        
        CFNotification.allNotificationsForCurrentUser { notifications, junctions, error2 in
          if let error2 = error2 as? NSError, error2.domain != NotFoundError.domain {
            handler(error2)
          } else {
            CFNotification.notificationsOfCurrentUser = notifications
            CFNotificationAndUser.junctionRecordsOfCurrentUser = junctions
            
            MainTabViewObserver.shared.notifications = CFNotification.notificationsOfCurrentUser ?? []
            MainTabViewObserver.shared.junctions = CFNotificationAndUser.junctionRecordsOfCurrentUser ?? []
            
            CFStudent.allStudentsForCurrentUser(completion: { error3, currentUserStudents in
              if let error3 = error3 as? NSError, error3.domain != NotFoundError.domain {
                handler(error3)
              } else {
                StudentsViewObserver.shared.allStudents = currentUserStudents
                
                CFClass.allClassesForCurrentUser { error4, currentUserClasses in
                  if let error4 = error4 as? NSError, error4.domain != NotFoundError.domain {
                    handler(error4)
                  } else {
                    HomeViewObserver.shared.allClasses = currentUserClasses
                    
                    CFRollCallSession.fetchAllRollCallSessionsRelatedToCurrentUser { error5, currentUserRollCallSessions in
                      if let error5 = error5 as? NSError, error5.domain != NotFoundError.domain {
                        handler(error5)
                      } else {
                        CFRollCallSession.allRollCallSessionsRelatedToCurrentUser = currentUserRollCallSessions
                        
                        CFClassAndStudent.fetchAllJunctionsForClasses(classIds: HomeViewObserver.shared.allClasses.map { $0.cid! }) { error6, allJunctionsOfCurrentUser in
                          if let error6 = error6 as? NSError, error6.domain != NotFoundError.domain {
                            handler(error6)
                          } else {
                            CFClassAndStudent.allJunctionsOfCurrentUser = allJunctionsOfCurrentUser
                            handler(nil)
                          }
                        }
                      }
                    }
                  }
                }
              }
            })
            return
          }
        }
      }
    }
  }
}

// https://github.com/zemirco/swift-timeago/blob/master/swift-timeago/TimeAgo.swift
func timeAgoSince(_ date: Date) -> String {
  
  let calendar = Calendar.current
  let now = Date()
  let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
  let components = (calendar as NSCalendar).components(unitFlags, from: date, to: now, options: [])
  
  if let year = components.year, year >= 2 {
    return "\(year) years ago"
  }
  
  if let year = components.year, year >= 1 {
    return "Last year"
  }
  
  if let month = components.month, month >= 2 {
    return "\(month) months ago"
  }
  
  if let month = components.month, month >= 1 {
    return "Last month"
  }
  
  if let week = components.weekOfYear, week >= 2 {
    return "\(week) weeks ago"
  }
  
  if let week = components.weekOfYear, week >= 1 {
    return "Last week"
  }
  
  if let day = components.day, day >= 2 {
    return "\(day) days ago"
  }
  
  if let day = components.day, day >= 1 {
    return "Yesterday"
  }
  
  if let hour = components.hour, hour >= 2 {
    return "\(hour) hours ago"
  }
  
  if let hour = components.hour, hour >= 1 {
    return "An hour ago"
  }
  
  if let minute = components.minute, minute >= 2 {
    return "\(minute) minutes ago"
  }
  
  if let minute = components.minute, minute >= 1 {
    return "A minute ago"
  }
  
  if let second = components.second, second >= 3 {
    return "\(second) seconds ago"
  }
  
  return "Just now"
}
