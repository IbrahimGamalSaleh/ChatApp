//
//  LoginViewController.swift
//  ChatApp
//
//  Created by IbrahimGamal on 7/6/19.
//  Copyright © 2019 IbrahimGamal. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase
import CoreData

class LoginViewController: UIViewController {

    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var dataController: DataController!
    fileprivate var _refHandle: DatabaseHandle!
    var indicator : UIActivityIndicatorView!
    var ref: DatabaseReference!
    let fireClass = FirebaseClass.sharedInstance()
    var storageRef: StorageReference!
    var errorString : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator = Helper.showSpinner(view: self)
        getPersonsFromFirebase()
    }
    @IBAction func loginPressed(_ sender: Any) {
        if IsDataCompleted()
        {
            indicator.startAnimating()
            fireClass.signInUser(email: emailField.text!, password: passwordField.text!) { (error, user) in
                if error != nil
                {
                    self.indicator.stopAnimating()
                    Helper.showAlert(title: "someThing wrong!", message: Helper.FirebaseErro(error: error!),view :self)
                }
                else{
                    self.indicator.stopAnimating()
                    self.performSegue(withIdentifier: "toChat", sender: user!)
                }
            }
      
        }
        else
        {
            Helper.showAlert(title: "Info not completed", message: "please Fill all data!",view :self)
        }
        
    }
    @IBAction func signupPressed(_ sender: Any) {
        performSegue(withIdentifier: "toSignUp", sender: self)
        
        
    }
    
    func IsDataCompleted()->Bool
    {
        errorString = "your "
        if emailField.text!.isEmpty
        {
            errorString += "( email ) "
        }
        
        if passwordField.text!.isEmpty
        {
            errorString += "( password ) "
        }
        errorString += " not completed"
        
        if emailField.text?.isEmpty != true && passwordField.text?.isEmpty != true
        {
            return true
        }
        else
        {
            return false
        }
    }
    // MARK: Config
   
    deinit {
        ref.child("messages").removeObserver(withHandle: _refHandle)
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "toSignUp" {
            let vc = segue.destination as! RegisterViewController
            vc.dataController = dataController
        }
        if segue.identifier == "toChat"
        {
            let user = sender as! User
            let object = Helper.getPersonById(id: user.uid, dataController: dataController)
            
            if object.found == false
            {
                let vc = segue.destination as! ChatTableViewController
                vc.dataController = dataController
                print("loginview person : \(String(describing: object.person))")
                vc.person = object.person!
                vc.user = user
            }
            
        }
    }
    
    
    func getPersonsFromFirebase() {
        let messageDB = Database.database().reference().child("person")
        
        messageDB.observe(.childAdded, with: { snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            let email = snapshotValue[Constants.PersonInfo.email] as! String
            let id = snapshotValue[Constants.PersonInfo.id] as! String
            let photo = snapshotValue[Constants.PersonInfo.photo] as! String
            let password = snapshotValue[Constants.PersonInfo.password] as! String
            let name = snapshotValue[Constants.PersonInfo.name] as! String
            print("hii")
            let object = Helper.getPersonById(id: id, dataController: self.dataController)
            if object.found
            {
                let person = Person(context: self.dataController.viewContext)
                
                person.email = email
                person.name =  name
                person.password = password
                person.id = id
                //person.photo =try Data(contentsOf: URL(fileURLWithPath: photo))
                try?  person.photo = Data(contentsOf: URL(string: photo)!)
                
                self.dataController.save()
                print("saved in database ")
                
            }
           
            
        })
    }
 
    
    
}


