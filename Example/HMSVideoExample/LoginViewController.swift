//
//  LoginViewController.swift
//  HMSVideo
//
//  Copyright (c) 2020 100ms. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var roomNameField: UITextField!
    @IBOutlet weak var userNameField: UITextField!
    
    @IBAction func loginPressed(_ sender: Any) {
        guard let roomName = roomNameField.text, let userName = userNameField.text, !userName.isEmpty, !roomName.isEmpty else {
            let alertController = UIAlertController(title: "Alert", message: "Please fill in all fields.", preferredStyle: .alert)
                    
            let action1 = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(action1)
            self.present(alertController, animated: true, completion: nil)
            
            return;
        }
        
        guard let meetingController = UIStoryboard(name: "Meeting", bundle: nil).instantiateInitialViewController() as? MeetingViewController else {
            return
        }
        
        meetingController.roomName = roomName
        meetingController.userName = userName
        navigationController?.pushViewController(meetingController, animated: true)
    }
}
