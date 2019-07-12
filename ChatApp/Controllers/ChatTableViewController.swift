//
//  ChatTableViewController.swift
//  ChatApp
//
//  Created by IbrahimGamal on 7/6/19.
//  Copyright © 2019 IbrahimGamal. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreData


class ChatTableViewController: UIViewController , UITableViewDelegate ,UITableViewDataSource , NSFetchedResultsControllerDelegate, UITextFieldDelegate{
   
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sendbtn: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    var storageRef: StorageReference!
    let firebaseClass = FirebaseClass.sharedInstance()
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        df.dateStyle = .medium
        return df
    }()
    var ref: DatabaseReference!
    var photoData : Data? = nil
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var user : User!
    var person:Person!
    var specificPerson:Person!
    
    var indicator : UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageField.delegate = self
        indicator = Helper.showSpinner(view: self)
        storageRef = Storage.storage().reference()
        ref = Database.database().reference()
        chatTableView.register(UINib(nibName: "CustomMessageCell", bundle: nil) , forCellReuseIdentifier: "customMessageCell")
        
        chatTableView.register(UINib(nibName: "MessagPhotoViewCell", bundle: nil) , forCellReuseIdentifier: "messagePhotoCell")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        chatTableView.addGestureRecognizer(tapGesture)
        
        configureTableView()
        
        setupFetchedResultsController()
       // deleteAllMessages()
        retrieveMessages()
        chatTableView.separatorStyle = .singleLine
        
        scrollToBottomMessage()
        
        // Do any additional setup after loading the view.
    }
    
    func deleteAllMessages()
    {
        for pic in fetchedResultsController.fetchedObjects as! [Message]
        {
            dataController.viewContext.delete(pic)
        }
        try? dataController.viewContext.save()
    }
    
    
    @IBAction func logoutPressed(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
        }
        catch {
            print(error)
            print("error: there was a problem logging out")
        }
        
        guard (navigationController?.popToRootViewController(animated: true)) != nil
            else {
                print("No View Controller to Pop")
                return
        }
    
    }
    @IBAction func cameraPressed(_ sender: Any) {
    
    
        let nextController=UIImagePickerController()
        nextController.delegate=self
        nextController.sourceType = .photoLibrary
        present(nextController,animated: true,completion: nil)
        
    }
    @IBAction func sendPressed(_ sender: Any) {
        
        indicator.startAnimating()
       configureView(enable: false)
        let messagesDB = Database.database().reference()
        let date = Date()
        let myString = dateFormatter.string(from: date)
        print("date : \(myString)")
        let id = UUID().uuidString
        
        let messageDictionary = [Constants.MessageInfo.userId: user.uid, Constants.MessageInfo.content : messageField.text!,Constants.MessageInfo.date:myString,Constants.MessageInfo.id:id,Constants.MessageInfo.photo:""]
        firebaseClass.putInFirebaseDatabase(ref: messagesDB, path: "Messages", data: messageDictionary) { (error) in
            if error != nil {
                print(error!)
                Helper.showAlert(title: "There is an error ", message: (error?.localizedDescription)!, view: self)
            }
            else {
                print("Message saved successfully!")
            }
            DispatchQueue.main.async {
                self.configureView(enable: true)
                 self.indicator.stopAnimating()
            }
        }
    }
    func configureView(enable:Bool)
    {
        messageField.isEnabled = enable
        sendbtn.isEnabled = enable
        if enable
        {
        self.messageField.text = ""
        }
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = fetchedResultsController.object(at: indexPath) as! Message
        
        if let msg = message.photo
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "messagePhotoCell", for: indexPath) as! MessagPhotoViewCell
            print("indextable from messagePhoto  : \(indexPath)")
            cell.messagePhoto.image = UIImage(data: msg)
            cell.userLabel.text = message.person?.name
            cell.userPhoto.image = UIImage(data: (message.person?.photo)!)
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
            print("indextable : \(indexPath)")
            cell.messageBody.text = message.content
            cell.senderUsername.text = message.person?.name
            cell.avatarImageView.image = UIImage(data: (message.person?.photo)!)
            return cell
        }
       
    }
    
    @objc func tableViewTapped() {
        messageField.endEditing(true)
    }
    func retrieveMessages() {
        let messageDB = Database.database().reference().child("Messages")
        
        messageDB.observe(.childAdded, with: { snapshot in
            
            //self.indicator.startAnimating()
            let snapshotValue = snapshot.value as! NSDictionary
            let content = snapshotValue[Constants.MessageInfo.content] as! String
            let userId = snapshotValue[Constants.MessageInfo.userId] as! String
            let photo = snapshotValue[Constants.MessageInfo.photo] as! String
            let id = snapshotValue[Constants.MessageInfo.id] as! String
            let date1 = snapshotValue[Constants.MessageInfo.date] as! String
            print("snapshotValue : \(content)")
            let date = self.dateFormatter.date(from: date1)
            
            if self.getMessageById(id: id) == false
            {
                print("hiii")
                let message = Message(context: self.dataController.viewContext)
                message.content = content
                message.date = date
                if photo.isEmpty != true{
                    try? message.photo = Data(contentsOf: URL(string: photo)!)
                }
                message.id = id
                message.userId = userId
                
                let found = Helper.getPersonById(id : userId, dataController: self.dataController)
                if found.found == false
                {
                    message.person = found.person!
                }
                
                self.dataController.save()
              
                print("saved in database ")
            }
            self.chatTableView.reloadData()
            //self.indicator.stopAnimating()
            self.scrollToBottomMessage()
            
           
            
        })
    }
   
    func getMessageById(id:String)->Bool
    {
        
        do
        {
            
            let fetchRequest = NSFetchRequest<Message>(entityName: "Message")
            let predicate = NSPredicate(format: "id == %@", argumentArray: [id])
            fetchRequest.predicate = predicate
            let objects = try dataController.viewContext.fetch(fetchRequest)
            
            if objects.isEmpty
            {
             return false
            }
            print("found :\(objects) ")
            return true
            
        }
        catch let error as NSError
        {
            print("failed to get  message data ")
            print(error.localizedDescription)
        return false
        }
        
    }
    func setupFetchedResultsController() {
        
       // var result : [Message]
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        //fetchRequest.predicate = NSPredicate(format: "pin = %@", pin)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
           } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    func scrollToBottomMessage() {
        if  fetchedResultsController.fetchedObjects?.count == 0 { return }
        let bottomMessageIndex = IndexPath(row: chatTableView.numberOfRows(inSection: 0) - 1, section: 0)
        chatTableView.scrollToRow(at: bottomMessageIndex, at: .bottom, animated: true)
    }
    
    //
    
    
    //TODO: Declare configureTableView here:
    
    func configureTableView() {
        userImageView.image = UIImage(data: person.photo!)
        userNameLabel.text = person.name
        chatTableView.rowHeight = UITableView.automaticDimension
        chatTableView.estimatedRowHeight = 120.0
    }
    
    
    
    //MARK: - TextField Delegate Methods
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
         
            chatTableView.insertRows(at: [newIndexPath!], with: .fade)
            print("insert : \([newIndexPath!])")
            //print("insert \(fetchedResultsController.fetchedObjects?.count)")
            
            break
        case .delete:
            chatTableView.deleteRows(at: [indexPath!], with: .fade)
            print("delete : \([indexPath])")
            break
        case .update:
            print("update : \([indexPath])")
            chatTableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            print("move : \([indexPath])")
            chatTableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
       
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: chatTableView.insertSections(indexSet, with: .fade)
        case .delete: chatTableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        chatTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        chatTableView.endUpdates()
    }
}
extension ChatTableViewController: UIImagePickerControllerDelegate ,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage  {
            photoData = image.jpegData(compressionQuality: 0.4)
      
            configureView(enable: false)
            indicator.startAnimating()
            firebaseClass.putInFirebaseStorage(photoData: self.photoData!, path: "messagePhoto", userId: self.user.uid, storageRef: storageRef) { (imageUrl, error) in
                if error == nil
                {
                    let date = Date()
                    let myString = self.dateFormatter.string(from: date)
                    print("date : \(myString)")
                    let id = UUID().uuidString
                    
                    let messageDictionary = [Constants.MessageInfo.userId: self.user.uid, Constants.MessageInfo.content :"",Constants.MessageInfo.date:myString,Constants.MessageInfo.id:id,Constants.MessageInfo.photo:imageUrl]
                    self.firebaseClass.putInFirebaseDatabase(ref: self.ref, path: "Messages", data: messageDictionary as! [String : String], { (error) in
                      
                        if error == nil{
                            print("photo saved ")
                        }
                        else{
                            Helper.showAlert(title: "there is an error", message: (error?.localizedDescription)!, view: self)
                        }
                    })
                    
                    self.indicator.stopAnimating()
                }
                else
                {
                    self.indicator.stopAnimating()
                    Helper.showAlert(title: "there is an error", message: (error?.localizedDescription)!, view: self)
                }
                
            }
            
        }
        dismiss(animated: true, completion: nil)
        configureView(enable: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
}
