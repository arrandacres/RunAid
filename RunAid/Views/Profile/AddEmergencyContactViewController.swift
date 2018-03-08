//
//  AddEmergencyContactViewController.swift
//  RunAid
//
//  Created by Arran Dacres on 07/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import UIKit
import AWSDynamoDB

class AddEmergencyContactViewController: UIViewController {
    
    @IBOutlet weak var AddByUsernameView: UIView!
    @IBOutlet weak var AddByPhoneNumberView: UIView!
    @IBOutlet weak var AddBySegmentControl: UISegmentedControl!
    var usernameVC: AddContactByUsernameVC?
    var usernameTextField: UITextField!
    var phoneNumberVC: AddContactByPhoneNumberVC?
    var phoneNumberTextField: UITextField!
    var reachability:Reachability?
    var delegate: ModalHandler?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.hideKeyboardWhenBackgroundTouched()
        AddByUsernameView.isHidden = false
        AddByPhoneNumberView.isHidden = true
    }
    
    //used to initialise the view controller objects - then used to retreive text field values
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "UsernameVCSegue"?:
            if let usernamevc = segue.destination as? AddContactByUsernameVC {
                usernameVC = usernamevc
                usernameTextField = usernamevc.UsernameTxtField
            }
        case "PhoneNumberVCSegue"?:
            if let phonenumbervc = segue.destination as? AddContactByPhoneNumberVC {
                phoneNumberVC = phonenumbervc
                phoneNumberTextField = phonenumbervc.PhoneNumberTxtField
            }
        default:
            break
        }
    }
    
    //display correct view when corresponding segment selected
    @IBAction func segment_changed(_ sender: UISegmentedControl) {
        switch AddBySegmentControl.selectedSegmentIndex{
        case 0:
            AddByUsernameView.isHidden = false
            AddByPhoneNumberView.isHidden = true
        case 1:
            AddByUsernameView.isHidden = true
            AddByPhoneNumberView.isHidden = false
        default: break
        }
    }
    
    @IBAction func addContact_pressed(_ sender: Any) {
        
        var contactDictionary = [String:String]()
        self.reachability = Reachability.init()
        
        switch AddBySegmentControl.selectedSegmentIndex {
        //if username segement selected use username text field value from username view controller
        case 0:
            if((self.reachability!.connection) != .none){
                if let username = usernameVC?.UsernameTxtField?.text {
                    
                    let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
                    
                    dynamoDBObjectMapper.load(RunAidUser.self, hashKey: username, rangeKey: nil).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
                        //Connection Error
                        if let error = task.error as NSError? {
                            print("Error: \(error)")
                            let alertController = self.CreateAlertWithActionButton(errorTitle: "Error connecting to database.", errorMessage: error.description)
                            self.present(alertController, animated: true, completion:  nil)
                        } else if let user = task.result as? RunAidUser {
                            //add user details as emergency contact
                            contactDictionary["username"] = user._username
                            contactDictionary["phone number"] = user._phoneNumber
                            var emergencyContacts = UserDefaults.standard.value(forKey: "EmergencyContacts") as? [[String:String]]
                            emergencyContacts?.append(contactDictionary)
                            UserDefaults.standard.set(emergencyContacts, forKey: "EmergencyContacts")
                            self.dismiss(animated: true){
                                self.delegate?.modalDismissed()
                            }
                        }else{
                            //No User returned
                            let alertController = self.CreateAlertWithActionButton(errorTitle: "Oops! We couldn't find that user.", errorMessage: "No user by that username exists.")
                            self.present(alertController, animated: true, completion:  nil)
                        }
                        return nil
                    })
                }
            }else{
                //No Internet Connection
                let alertController = self.CreateAlertWithActionButton(errorTitle: "No Internet connection!", errorMessage: "You need to be connected to the internet to add an emergency contact by username.")
                self.present(alertController, animated: true, completion:  nil)
            }

        //if phone number segment slected use phone number text field value from phone number view controller
        case 1:
            if let phonenumber = phoneNumberVC?.PhoneNumberTxtField?.text {
                contactDictionary["username"] = String()
                contactDictionary["phone number"] = phonenumber
                var emergencyContacts = UserDefaults.standard.value(forKey: "EmergencyContacts") as? [[String:String]]
                emergencyContacts?.append(contactDictionary)
                UserDefaults.standard.set(emergencyContacts, forKey: "EmergencyContacts")
            }
            self.dismiss(animated: true){
                self.delegate?.modalDismissed()
            }
        default:
            self.dismiss(animated: true){
                self.delegate?.modalDismissed()
            }
        }
    }

    //close view controller when exit button pressed
    @IBAction func exitButton_pressed(_ sender: Any) {
        DispatchQueue.main.async {
            self.presentingViewController?.dismiss(animated: true){
                self.delegate?.modalDismissed()
            }
        }
    }
}

//When user presses return key in Username field automatically jumps to password field
//code interpreted from: https://cocoacasts.com/five-simple-tips-to-make-user-friendly-forms-on-ios
extension AddEmergencyContactViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameTextField:
            usernameVC?.UsernameTxtField.resignFirstResponder()
        case phoneNumberTextField:
            phoneNumberVC?.PhoneNumberTxtField.resignFirstResponder()
        default:
            break
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(edittedTextField: textField, distanceToMove: 200, upwards: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(edittedTextField: textField, distanceToMove: 200, upwards: false)
    }
    
    func moveTextField(edittedTextField: UITextField, distanceToMove: Int, upwards: Bool){
        
        UIView.beginAnimations("moveTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(0.3)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: CGFloat(upwards ? -distanceToMove : distanceToMove))
        UIView.commitAnimations()
    }
}
