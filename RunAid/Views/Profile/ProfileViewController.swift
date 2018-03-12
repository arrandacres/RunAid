//
//  FirstViewController.swift
//  RunAid
//
//  Created by Arran Dacres on 21/02/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import WatchConnectivity

//protocol to implement to handler dimissing of modally presented views
protocol ModalHandler {
    func modalDismissed()
}

class ProfileViewController: UIViewController, ModalHandler {

    var user:AWSCognitoIdentityUser?
    var userAttributes:[AWSCognitoIdentityProviderAttributeType]?
    var wcSession : WCSession!
    var reachability:Reachability?
    var emergencyContacts: [[String:String]] = [[String:String]]()
    
    @IBOutlet weak var UsernameLbl: UILabel!
    @IBOutlet weak var emailAddressLbl: UILabel!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    @IBOutlet weak var emergencyContactsTable: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.reachability = Reachability.init()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        //Emergency Contact Table Initialisation
        emergencyContactsTable.dataSource = self
        emergencyContactsTable.delegate = self
        
        //set labels
        UsernameLbl.text = UserDefaults.standard.value(forKey: "Username") as? String
        emailAddressLbl.text = UserDefaults.standard.value(forKey: "EmailAddress") as? String
        phoneNumberLbl.text = UserDefaults.standard.value(forKey: "PhoneNumber") as? String
        emergencyContacts = (UserDefaults.standard.value(forKey: "EmergencyContacts") as? [[String:String]])!
        //self.user = AppDelegate.getUserPool().currentUser()!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wcSession = self.setUpWatchConnection()
    }
    
    //Send Message to Apple Watch
    @IBAction func SendMsg_Pressed(_ sender: Any) {
        
        wcSession.sendMessage(constructData(), replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //constructs dictionary of username and user details to send to Apple Watch
    private func constructData() -> [String:AnyObject] {
        
        var dataDictionary = [String: AnyObject]()
        dataDictionary["Username"] = user?.username as AnyObject
        if let attributes = userAttributes
        {
            for attribute in attributes {
                dataDictionary[attribute.name!] = attribute.value as AnyObject
            }
        }
        return dataDictionary
    }
    
    //Modal View Dismissed causes reload of the data in the emergency contacts table - to include
    //any additional contacts added
    func modalDismissed() {
        emergencyContactsTable.reloadData()
    }
    
    //used to set delegate object on the 'AddEmergencyContactSegue' modal view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "AddEmergencyContactSeque") {
            let vc = segue.destination as! AddEmergencyContactViewController
            vc.delegate = self
        }
    }
    
    
    
    //Logs user out and return to the Login View
    @IBAction func logoutBtn_pressed(_ sender: AnyObject) {
        let signOutAlert = UIAlertController(title: "Are you sure you want to log out?", message: "", preferredStyle: .alert)
        signOutAlert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        signOutAlert.addAction(UIAlertAction(title: "Yes", style: .default){ (action:UIAlertAction!) in
            
            //clear UserDefaults
            let defaults = UserDefaults.standard
            let dictionary = defaults.dictionaryRepresentation()
            dictionary.keys.forEach { key in
                defaults.removeObject(forKey: key)
            }
            
            self.user?.signOut()
            self.user?.getDetails()
        })
        self.present(signOutAlert, animated: true)
        
    }
}

//Delegate used for updating table
extension ProfileViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emergencyContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let emergencyContactDetails = emergencyContacts[indexPath.row]
        
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "EmergencyContactCell") as! EmergencyContactCell
        tableCell.usernameLbl.text = emergencyContactDetails.filter { $0.key == "username"}.first?.value
        tableCell.phoneNumberLbl.text = emergencyContactDetails.filter { $0.key == "phone number"}.first?.value
        return tableCell
    }
    
    //implements sliding from right to left delete option on table cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            emergencyContacts.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    
}

