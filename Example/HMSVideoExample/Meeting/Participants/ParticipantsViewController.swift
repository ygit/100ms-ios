//
//  ParticipantsViewController.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 28/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSVideo

class ParticipantsViewController: UIViewController {

    @IBOutlet weak var table: UITableView!

    var hms: HMSInterface?

    var peers: [HMSPeer] {
        hms?.peers.map { $0.1 } ?? [HMSPeer]()
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Action Handlers

    @IBAction func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension ParticipantsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        peers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.resuseIdentifier, for: indexPath)

        let peer = peers[indexPath.row]

        cell.textLabel?.text = peer.name

        if peer.role == "Host" {
            cell.detailTextLabel?.text = peer.role
        }

        return cell
    }
}

extension ParticipantsViewController: UITableViewDelegate {

}
