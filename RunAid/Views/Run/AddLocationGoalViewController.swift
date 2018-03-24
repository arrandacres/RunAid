//
//  AddLocationGoalViewController.swift
//  RunAid
//
//  Created by Arran Dacres on 21/03/2018.
//  Copyright © 2018 Arran Dacres. All rights reserved.
//

import UIKit

class AddLocationGoalViewController: UIViewController {
    
    @IBOutlet weak var TimePicker: UIDatePicker!
    
    var saveTimeInterval: ((_ timeInterval: TimeInterval) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setting default value of the time picker to 30 minutes
        //also needed to avoid TimePicker appending seconds based upon the time the app is ran
        TimePicker.countDownDuration = 1800.0
    }

    @IBAction func create_goal_pressed(_ sender: Any) {
        print(TimePicker.countDownDuration)
        saveTimeInterval?(TimePicker.countDownDuration)
        self.dismiss(animated: true, completion: nil)
    }
    
    //dismiss modal view
    @IBAction func exit_button_pressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
