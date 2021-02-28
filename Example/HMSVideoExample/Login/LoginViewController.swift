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
            nameField.text = UserDefaults.standard.string(forKey: "name") ?? "iOS User"
        }
    }

    @IBOutlet private weak var meetingIDField: UITextField! {
        didSet {
            Utilities.drawCorner(on: meetingIDField)
            meetingIDField.text = UserDefaults.standard.string(forKey: "room") ?? "Enter Meeting ID"
//            meetingIDField.text = "6033b4cb89a96e73b23d13dc"
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
            meetingNameField.text = UserDefaults.standard.string(forKey: "meeting") ?? "Enter Meeting Name"
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
        guard let roomName = meetingIDField.text,
              let user = nameField.text,
              !user.isEmpty, !roomName.isEmpty
        else {
            showAlert(with: Constants.emptyFields)
            return
        }

        guard let viewController = UIStoryboard(name: Constants.meeting, bundle: nil)
                .instantiateInitialViewController() as? MeetingViewController else {
            return
        }

        viewController.user = user
        viewController.roomName = roomName
        viewController.flow = .join

        save(user, roomName)

        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction private  func startMeetingTapped(_ sender: UIButton) {

        guard let roomName = meetingNameField.text else {
            showAlert(with: Constants.emptyFields)
            return
        }

        let user = UserDefaults.standard.string(forKey: Constants.defaultName) ?? "iOS User"

        guard let viewController = UIStoryboard(name: Constants.meeting, bundle: nil)
                .instantiateInitialViewController() as? MeetingViewController else {
            return
        }

        viewController.user = user
        viewController.roomName = roomName
        viewController.flow = .start

        save(user, roomName)

        navigationController?.pushViewController(viewController, animated: true)
    }

    func showAlert(with message: String) {
        let alertController = UIAlertController(title: "Alert",
                                                message: message,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .default))

        self.present(alertController, animated: true, completion: nil)
    }

    func save(_ name: String, _ room: String, _ meeting: String? = nil) {
        let userDefaults = UserDefaults.standard

        userDefaults.set(name, forKey: "name")
        userDefaults.set(room, forKey: "room")

        if let meeting = meeting {
            userDefaults.set(meeting, forKey: "meeting")
        }
    }

    @IBAction func settingsTapped(_ sender: UIButton) {
        guard let viewController = UIStoryboard(name: Constants.settings, bundle: nil)
                .instantiateInitialViewController() as? SettingsViewController
        else {
            return
        }

        present(viewController, animated: true)
    }
}
