//
//  ChatViewController.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 28/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var table: UITableView!
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
}

extension ChatViewController: UITableViewDelegate {
    
}
