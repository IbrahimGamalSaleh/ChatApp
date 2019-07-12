//
//  Helper.swift
//  ChatApp
//
//  Created by IbrahimGamal on 7/6/19.
//  Copyright © 2019 IbrahimGamal. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreData

class Helper  {
    
  static  func showAlert(title: String, message: String, view : UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
            alert.addAction(dismissAction)
            view.present(alert, animated: true, completion: nil)
        }
    }
 static   func FirebaseErro (error : Error)->String
    {
        if let errCode = AuthErrorCode(rawValue: error._code) {
            
            switch errCode {
            case .invalidEmail:
                return "invalid email"
            case .emailAlreadyInUse:
                return "email is in use"
                
            case .weakPassword:
                return "Weak Password"
        
            case .wrongPassword:
                return " Wrong password!"
                
            default:
                return "Create User Error: \(error)"
                
            }
        }
        return "Create User Error: \(error)"
    }
    
    static func showSpinner(view : UIViewController) -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        DispatchQueue.main.async(execute: {
            spinner.center = view.view.center
            spinner.color = UIColor.orange
            view.view.addSubview(spinner)
     //       spinner.startAnimating()
        })
        
        return spinner
    }
    
    static func getPersonById(id:String , dataController : DataController)->(found:Bool,person:Person?)
    {
        
        var person : Person!
        do
        {
            
            let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
            let predicate = NSPredicate(format: "id == %@", argumentArray: [id])
            fetchRequest.predicate = predicate
            let pers = try dataController.viewContext.fetch(fetchRequest)
            
            if pers.isEmpty {
                return (true,person)
            }
            person = pers[0]
            return (false,person)
        }
        catch let error as NSError
        {
            print("failed to get pin by person data ")
            print(error.localizedDescription)
            
            return (true,person)
        }
        
    }
}
