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

    var hms: HMSInteractor?

    var peers: [HMSPeer] {
        var peers = hms?.peers.map { $0.1 } ?? [HMSPeer]()
        let host = peers.filter { $0.role?.lowercased() == "host" }
        if peers.count > 0, host.count > 0 {
            peers.removeAll { $0.role?.lowercased() == "host" }
            host.forEach { peers.insert($0, at: 0) }
        }
        return peers
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        observeParticipants()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Action Handlers

    func observeParticipants() {
        _ = NotificationCenter.default.addObserver(forName: Constants.peersUpdated,
                                                   object: nil,
                                                   queue: .main) { [weak self] _ in
            self?.table.reloadData()
        }
    }

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
        cell.detailTextLabel?.text = peer.role?.capitalized ?? "Guest"

        return cell
    }
}

extension ParticipantsViewController: UITableViewDelegate {

}
