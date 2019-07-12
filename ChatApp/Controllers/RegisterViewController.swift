//
//  RegisterViewController.swift
//  ChatApp
//
//  Created by IbrahimGamal on 7/6/19.
//  Copyright © 2019 IbrahimGamal. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class RegisterViewController: UIViewController {

    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    var dataController: DataController!
    var user:User!
    let firebaseClass = FirebaseClass.sharedInstance()
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var photoData : Data? = nil
    var errorString : String!
    var indicator : UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        passwordField.delegate=self
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        indicator = Helper.showSpinner(view: self)
    }
    
    @IBAction func imagePressed(_ sender: Any) {
        
        let nextController=UIImagePickerController()
        nextController.delegate=self
        nextController.sourceType = .photoLibrary
        present(nextController,animated: true,completion: nil)
        
        
    }
    
   func IsDataCompleted()->Bool
     {
        errorString = "your "
        if photoData == nil
        {
            errorString += "( photo clickOnAvatar ) "
        }
        if usernameField.text!.isEmpty
        {
            errorString += "( name ) "
        }
        
        if emailField.text!.isEmpty
        {
            errorString += "( email ) "
        }
        
        if passwordField.text!.isEmpty
        {
            errorString += "( password ) "
        }
        errorString += " not completed"
        if photoData != nil && usernameField.text?.isEmpty != true && emailField.text?.isEmpty != true && passwordField.text?.isEmpty != true
        {
            return true
        }
        else
        {
            return false
        }
    
    }
    @IBAction func registerPressed(_ sender: Any) {
        if IsDataCompleted()
        {
            indicator.startAnimating()
            firebaseClass.createUser(email: emailField.text!, password: passwordField.text!) { (error, user) in
                if error == nil{
                    print("Created Succesfuly ")
                    self.user = user!
                    self.firebaseClass.putInFirebaseStorage(photoData: self.photoData!, path: "personsPhoto", userId: user!.uid, storageRef: self.storageRef, { (imageUrl, error) in
                        if error != nil
                        {
                            print("Error uploading: \(String(describing: error))")
                        }
                        else
                        {
                            let data = [Constants.PersonInfo.email:self.emailField.text!,Constants.PersonInfo.name:self.usernameField.text!,Constants.PersonInfo.password:self.passwordField.text!,Constants.PersonInfo.photo:imageUrl,Constants.PersonInfo.id:user!.uid]
                            self.firebaseClass.putInFirebaseDatabase(ref: self.ref, path: "person", data: data as! [String : String], { (error) in
                                if error == nil{
                                    print("photo saved ")
                                }
                            })
                            
                        }
                    })
                    self.indicator.stopAnimating()
                    self.performSegue(withIdentifier: "toChat", sender: self)
                    
                }
                else
                {
                     self.indicator.stopAnimating()
                    Helper.showAlert(title: "someThing wrong!", message: Helper.FirebaseErro(error: error!),view :self)
                }
            }
        }
        else
        {
             Helper.showAlert(title: "Info not completed", message: errorString,view :self)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChat"
        {
            let person = Person(context: dataController.viewContext)
            
            person.email = emailField.text!
            person.name =  usernameField.text!
            person.password = passwordField.text!
            person.id = user.uid
            person.photo = photoData
            dataController.save()
            print("saved in database ")
            
            let vc = segue.destination as! ChatTableViewController
            vc.dataController = dataController
            vc.person = person
            vc.user = user
        }
    }

}
extension RegisterViewController: UIImagePickerControllerDelegate ,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage  {
            self.photoData = image.jpegData(compressionQuality: 0.4)
            userImage.image=image
            
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
}
extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if passwordField.isEditing
        {
            view.frame.origin.y -= (getKeyboardHeight(notification)*0.5)
        }
    }
    @objc func keyboardWillHide(_ notification:Notification) {
        
        view.frame.origin.y = 0
    }
    
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
}
