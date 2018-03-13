//
//  InterfaceController.swift
//  RunAidWatchApp Extension
//
//  Created by Arran Dacres on 28/02/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class HomeController: WKInterfaceController {
    
    @IBOutlet var usernameLbl: WKInterfaceLabel!
    
    @IBOutlet var emailAddrLbl: WKInterfaceLabel!
    var wcSession: WCSession!

    
    //Message received from iPhone function
    override func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Data Received: ", message)
        if let username = message["Username"]  as? String {
            self.usernameLbl.setText(username)
        }
        if let emailAddr = message["email"]  as? String {
            self.emailAddrLbl.setText(emailAddr)
        }
    }
    
    //Ran when watch app view controller initialised
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
    }
    

    //send message back to iPhone
    @IBAction func SendMsgBtn_Pressed() {
        wcSession.sendMessage(["Watch Message":"Hello from Watch!"], replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
    }
}

