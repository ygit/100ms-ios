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
    
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var stackView: UIStackView! 
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    // MARK: - View Modifiers
    
    @objc func keyboardWillShow(notification:NSNotification) {

        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification:NSNotification) {

        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    
    // MARK: - Action Handlers
    
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
