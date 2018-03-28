//
//  EmergencyContactsAlertViewController.swift
//  RunAid
//
//  Created by Arran Dacres on 22/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import UIKit
import MapKit
import MessageUI
import ButtonProgressBar_iOS
import UIColor_Hex_Swift
import WatchConnectivity

class EmergencyContactsAlertViewController: UIViewController {
    
    @IBOutlet private weak var alertTitleLabel: UILabel!
    @IBOutlet private weak var alertCountdownLabel: UILabel!
    @IBOutlet private weak var sendSOSButton: ButtonProgressBar!
    @IBOutlet private weak var cancelAlertButton: ButtonProgressBar!
    
    @IBOutlet weak var stackView: UIStackView!
    
    private var alertTimer: Timer?
    private var alertCountdown = 10
    
    private var cancelButtonTimer: Timer?
    private var sosButtonTimer: Timer?
    
    var wcSession: WCSession!
    var alertType: AlertType = AlertType.LocationGoal
    
    var emergencyAlertRequested: ((_ alertRequested: Bool) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAlertContent()
        configureAnimatedButtons()
        //wcSession = self.setUpWatchConnection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        alertCountdown = 10     //reset countdown
        alertTimer = startTimer()       //start timer with time interval of 1 second
        self.sendAppleWatchMessage(session: wcSession, message: ["SendingAlert":true])
    }
    
    //configure long-press animated buttons
    private func configureAnimatedButtons(){
        sendSOSButton.frame.size = CGSize(width:(stackView.frame.width/2)-20 ,height:stackView.frame.height)
        sendSOSButton.layer.cornerRadius = (sendSOSButton.frame.height / 5)
        sendSOSButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        sendSOSButton.setBackgroundColor(color: UIColor("#D0021B"))
        sendSOSButton.setProgressColor(color: UIColor("#E53532"))
        
        cancelAlertButton.frame.size = CGSize(width: (stackView.frame.width/2)-20 ,height:stackView.frame.height)
        cancelAlertButton.layer.cornerRadius = (cancelAlertButton.frame.height / 5)
        cancelAlertButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        cancelAlertButton.setBackgroundColor(color: UIColor("#434343"))
        cancelAlertButton.setProgressColor(color: UIColor("#B3B3B3"))
    }
    
    //creates and starts timer
    private func startTimer() -> Timer {
        return Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            //if coundown hasn't reached 0 then decrement countdown and update label
            if self.alertCountdown > 0 {
                self.alertCountdown -= 1
                self.alertCountdownLabel.text = "Your Emergency Contacts will be contacted in \(self.alertCountdown) seconds"
            }else{
                //else stop timer, request an emergency alert, and dismiss view controller
                self.alertTimer?.invalidate()
                //self.emergencyAlertRequested?(true)
                self.dismiss(animated: true, completion: {
                    self.emergencyAlertRequested?(true)
                })
            }
        }
    }
    
    @IBAction func send_SOS_long_press(_ sender: UILongPressGestureRecognizer) {
        //when user begins pressing button - stop the alert timer (so an alert isn't sent whilst user is attempting to cancel alert & create a timer which every 0.1 seconds animates the button - creating the progress effect
        switch sender.state{
        case .began:
            sosButtonTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.animateButton(sender: self.sosButtonTimer!, button: self.sendSOSButton, isCancel:false)
            }
        //when user ends pressing button - reset progress of the button, stop the cancel button timer created when they begin pressing the button - to stop any further animation of the button, & restart the alert timer to continue the countdown
        case .ended:
            self.sendSOSButton.resetProgress()
            self.sendSOSButton.setProgress(progress: 0, true)
            sosButtonTimer?.invalidate()
            
        default:
            break
        }
        
    }
    
    @IBAction func cancel_long_press(_ sender: UILongPressGestureRecognizer) {
        //when user begins pressing button - stop the alert timer (so an alert isn't sent whilst user is attempting to cancel alert & create a timer which every 0.1 seconds animates the button - creating the progress effect
        switch sender.state{
        case .began:
            self.alertTimer?.invalidate()
            cancelButtonTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.animateButton(sender: self.cancelButtonTimer!, button: self.cancelAlertButton,isCancel: true)
            }
        //when user ends pressing button - reset progress of the button, stop the cancel button timer created when they begin pressing the button - to stop any further animation of the button, & restart the alert timer to continue the countdown
        case .ended:
            self.cancelAlertButton.resetProgress()
            self.cancelAlertButton.setProgress(progress: 0, true)
            cancelButtonTimer?.invalidate()
            self.alertTimer = startTimer()
        default:
            break
        }
    }
    
    //animate given button
    @objc func animateButton(sender: Timer, button: ButtonProgressBar, isCancel: Bool) {
        //if the progress of the button is 0.4 (progress full on button) then stop the timer, and dismiss the View Controller
        if button.progress >= 0.4 {
            if isCancel {
            sender.invalidate()
            self.sendAppleWatchMessage(session: wcSession, message: ["SendingAlert":false])
            self.dismiss(animated: true)
            }else{
                sender.invalidate()
                self.dismiss(animated: true, completion: {
                    self.emergencyAlertRequested?(true)
                })
            }
        }
            //if the progress is not filled; update the progress on the button
        else {
            button.setProgress(progress: button.progress + CGFloat(0.03), true)
        }
    }
    
    //set alert content based upon alert type
    private func setAlertContent() {
        //set countdown label
        self.alertCountdownLabel.text = "Your Emergency Contacts will be contacted in \(self.alertCountdown) seconds"
        //set alert specific text
        switch alertType {
        case .LocationGoal:
            alertTitleLabel.text = "Safety Location Goal not reached"
        case .NoMovement:
            alertTitleLabel.text = "No Movement Detected"
        }
    }
}
