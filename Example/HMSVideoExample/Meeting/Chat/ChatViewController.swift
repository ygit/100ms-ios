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
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        observeBroadcast()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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

        cell.detailTextLabel?.font = .preferredFont(forTextStyle: .body)
        cell.detailTextLabel?.text = message

        return cell
    }
}

extension ChatViewController: UITableViewDelegate {

}
