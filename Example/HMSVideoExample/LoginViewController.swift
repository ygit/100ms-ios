//
//  LoginViewController.swift
//  HMSVideo
//
//  Copyright (c) 2020 100ms. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - View Properties

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var joinNowStackView: UIStackView! {
        didSet {
            Utilities.applyBorder(on: joinNowStackView)
        }
    }

    @IBOutlet weak var nameField: UITextField! {
        didSet {
            Utilities.applyBorder(on: nameField)
        }
    }

    @IBOutlet weak var meetingIDField: UITextField! {
        didSet {
            Utilities.drawCorner(on: meetingIDField)
        }
    }

    @IBOutlet weak var joinNowButton: UIButton! {
        didSet {
            Utilities.drawCorner(on: joinNowButton)
        }
    }

    @IBOutlet weak var startMeetingStackView: UIStackView! {
        didSet {
            Utilities.applyBorder(on: startMeetingStackView)
        }
    }

    @IBOutlet weak var meetingNameField: UITextField! {
        didSet {
            Utilities.drawCorner(on: meetingNameField)
        }
    }
    @IBOutlet weak var recordSwitch: UISwitch!
    @IBOutlet weak var startMeetingButton: UIButton! {
        didSet {
            Utilities.drawCorner(on: startMeetingButton)
        }
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        handleKeyboard()
    }

    // MARK: - View Modifiers

    func handleKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))
    }

    @objc func keyboardWillShow(notification: NSNotification) {

        guard let userInfo = notification.userInfo,
              var keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        else { return }

        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification: NSNotification) {

        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }

    // MARK: - Action Handlers

    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.resignFirstResponder()
    }

    @IBAction func joinNowTapped(_ sender: UIButton) {
        guard let roomName = meetingIDField.text,
              let userName = nameField.text,
              !userName.isEmpty, !roomName.isEmpty
        else {
            let alertController = UIAlertController(title: "Alert",
                                                    message: "Please fill in all fields.",
                                                    preferredStyle: .alert)

            let action1 = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(action1)
            self.present(alertController, animated: true, completion: nil)

            return
        }

        guard let meetingController = UIStoryboard(name: "Meeting", bundle: nil)
                .instantiateInitialViewController() as? MeetingViewController
        else {
            return
        }

        meetingController.roomName = roomName
        meetingController.userName = userName
        navigationController?.pushViewController(meetingController, animated: true)
    }

    @IBAction func startMeetingTapped(_ sender: UIButton) {
    }
}
