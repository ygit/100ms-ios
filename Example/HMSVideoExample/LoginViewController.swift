//
//  LoginViewController.swift
//  HMSVideo
//
//  Copyright (c) 2020 100ms. All rights reserved.
//

import UIKit
import QuartzCore

class LoginViewController: UIViewController {
    
    // MARK: - View Properties
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var joinNowStackView: UIStackView! {
        didSet {
            if #available(iOS 11.0, *) {
                joinNowStackView.layer.borderColor = UIColor(named: "Border")?.cgColor
            } else {
                joinNowStackView.layer.borderColor = UIColor.black.cgColor
            }
            joinNowStackView.layer.borderWidth = 1
            joinNowStackView.layer.cornerRadius = 12
            joinNowStackView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var meetingIDField: UITextField!
    @IBOutlet weak var joinNowButton: UIButton! {
        didSet {
            joinNowButton.layer.cornerRadius = 12
            joinNowButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var startMeetingStackView: UIStackView! {
        didSet {
            if #available(iOS 11.0, *) {
                startMeetingStackView.layer.borderColor = UIColor(named: "Border")?.cgColor
            } else {
                startMeetingStackView.layer.borderColor = UIColor.black.cgColor
            }
            
            startMeetingStackView.layer.borderWidth = 1
            startMeetingStackView.layer.cornerRadius = 12
            startMeetingStackView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var meetingNameField: UITextField!
    @IBOutlet weak var recordSwitch: UISwitch!
    @IBOutlet weak var startMeetingButton: UIButton! {
        didSet {
            startMeetingButton.layer.cornerRadius = 12
            startMeetingButton.layer.masksToBounds = true
        }
    }
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        handleKeyboard()
    }
    
    
    // MARK: - View Modifiers
    
    func handleKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))
    }
    
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
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.resignFirstResponder()
    }
    
    @IBAction func joinNowTapped(_ sender: UIButton) {
        guard let roomName = meetingIDField.text, let userName = nameField.text, !userName.isEmpty, !roomName.isEmpty else {
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
    
    @IBAction func startMeetingTapped(_ sender: UIButton) {
    }
}
