//
//  FirebaseClass.swift
//  ChatApp
//
//  Created by IbrahimGamal on 7/9/19.
//  Copyright © 2019 IbrahimGamal. All rights reserved.
//

import Foundation
import CoreData
import Firebase

class FirebaseClass{
    
     func signInUser(email: String, password: String, _ completionHandlerForSignIn: @escaping (_ error: Error?, _ user: User?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password){ [weak self] user, error in
            guard self != nil else {
               completionHandlerForSignIn(error,user?.user)
                return
                }
 
            completionHandlerForSignIn(error,user?.user)
          
        }
    }
    
    func createUser(email: String, password: String, _ completionHandlerForCreateUser: @escaping (_ error: Error?, _ user: User?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            completionHandlerForCreateUser(error,result?.user)
        }
    }
    
    func putInFirebaseStorage(photoData: Data,path : String,userId : String,storageRef : StorageReference, _ completionHandlerForStorage: @escaping (_ imageUrl : String? ,_ error : Error? ) -> Void)
    {
        let imagePath = "\(path)/" + userId + ".jpg"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        storageRef.child(imagePath).putData(photoData, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error uploading: \(error)")
                completionHandlerForStorage(nil,error)
            }
            else
            {
            storageRef.child((metadata?.path)!).downloadURL { url, error in
                
                if let error = error {
                    // Handle any errors
                    print("error : \(error)")
                completionHandlerForStorage(nil,error)
                }
               else
                {
                let imageUrl = (url?.absoluteString)!
                print("imageUrl : \(imageUrl)")
                completionHandlerForStorage(imageUrl,error)
                }
            }
        }
    }
        
}
    func putInFirebaseDatabase(ref: DatabaseReference, path: String,data : [String:String], _ completionHandlerForDatabase: @escaping (_ error : Error? ) -> Void)
    {
        ref.child(path).childByAutoId().setValue(data){
            (error, ref) in
            
            completionHandlerForDatabase(error)
        }
    }
    
    class func sharedInstance() -> FirebaseClass {
        struct Singleton {
            static let sharedInstance = FirebaseClass()
        }
        return Singleton.sharedInstance
    }
}
