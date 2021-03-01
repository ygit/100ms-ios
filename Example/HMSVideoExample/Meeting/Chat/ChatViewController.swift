//
//  ChatViewController.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 28/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    var hms: HMSInterface!

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        table.tableFooterView = UIView()
        table.estimatedRowHeight = 64
        table.rowHeight = UITableView.automaticDimension
        table.tableFooterView = stackView

        observeBroadcast()
        handleKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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

        var contentInset = table.contentInset
        contentInset.bottom = keyboardFrame.size.height + 30
        table.contentInset = contentInset
    }

    @objc private func keyboardWillHide(notification: NSNotification) {

        let contentInset = UIEdgeInsets.zero
        table.contentInset = contentInset
    }

    // MARK: - Action Handlers

    func observeBroadcast() {
        _ = NotificationCenter.default.addObserver(forName: Constants.broadcastReceived,
                                                   object: nil,
                                                   queue: .main) { [weak self] _ in
            self?.table.reloadData()
        }
    }

    @IBAction func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func sendTapped(_ sender: UIButton) {

        if let message = textField.text, !message.isEmpty {

            sender.isEnabled = false

            let broadcast = [Constants.chatSenderName: hms.localPeer.name, Constants.chatMessage: message]

            hms.send(broadcast) {

                sender.isEnabled = true
                self.textField.text = nil
                self.hms.broadcasts.append(broadcast)
                self.table.reloadData()
                let index = IndexPath(row: self.hms.broadcasts.count - 1, section: 0)
                self.table.scrollToRow(at: index, at: .top, animated: true)
            }
        }
    }
}

extension ChatViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        hms.broadcasts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.resuseIdentifier, for: indexPath)

        let chat = hms.broadcasts[indexPath.row]

        guard let sender = chat[Constants.chatSenderName] as? String,
              let message = chat[Constants.chatMessage] as? String
        else {
            return UITableViewCell()
        }

        cell.textLabel?.font = .preferredFont(forTextStyle: .headline)
        cell.textLabel?.text = sender

        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping

        cell.detailTextLabel?.font = .preferredFont(forTextStyle: .body)

        cell.detailTextLabel?.text = message

        return cell
    }

    private func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        50
    }
}

extension ChatViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped(sendButton)
        return true
    }
}
