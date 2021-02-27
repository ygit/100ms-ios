//
//  LoginViewController.swift
//  HMSVideo
//
//  Copyright (c) 2020 100ms. All rights reserved.
//

import UIKit

final class LoginViewController: UIViewController {

    // MARK: - View Properties

    @IBOutlet private weak var scrollView: UIScrollView!

    @IBOutlet private weak var joinNowStackView: UIStackView! {
        didSet {
            Utilities.applyBorder(on: joinNowStackView)
        }
    }

    @IBOutlet private weak var nameField: UITextField! {
        didSet {
            Utilities.applyBorder(on: nameField)
        }
    }

    @IBOutlet private weak var meetingIDField: UITextField! {
        didSet {
            Utilities.drawCorner(on: meetingIDField)
        }
    }

    @IBOutlet private weak var joinNowButton: UIButton! {
        didSet {
            Utilities.drawCorner(on: joinNowButton)
        }
    }

    @IBOutlet private weak var startMeetingStackView: UIStackView! {
        didSet {
            Utilities.applyBorder(on: startMeetingStackView)
        }
    }

    @IBOutlet private weak var meetingNameField: UITextField! {
        didSet {
            Utilities.drawCorner(on: meetingNameField)
        }
    }

    @IBOutlet private weak var recordSwitch: UISwitch!

    @IBOutlet private weak var startMeetingButton: UIButton! {
        didSet {
            Utilities.drawCorner(on: startMeetingButton)
        }
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        handleKeyboard()
    }

    // MARK: - View Modifiers

    private func handleKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {

        guard let userInfo = notification.userInfo,
              var keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        else { return }

        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }

    @objc private func keyboardWillHide(notification: NSNotification) {

        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }

    // MARK: - Action Handlers

    @IBAction private func joinNowTapped(_ sender: UIButton) {
        guard let room = meetingIDField.text,
              let user = nameField.text,
              !user.isEmpty, !room.isEmpty
        else {
            showAlert(with: Constants.emptyFields)
            return
        }

        guard let viewController = MeetingViewController.make(with: Constants.endpoint,
                                                              token: Constants.token,
                                                              user: user,
                                                              room: room)
        else {
            showAlert(with: Constants.meetingError)
            return
        }

        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction private  func startMeetingTapped(_ sender: UIButton) {
    }

    func showAlert(with message: String) {
        let alertController = UIAlertController(title: "Alert",
                                                message: message,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .default))

        self.present(alertController, animated: true, completion: nil)
    }
}
