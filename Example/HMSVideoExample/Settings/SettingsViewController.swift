//
//  SettingsViewController.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 27/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var table: UITableView!
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Action Handlers

    @IBAction func closeTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 5
        case 2:
            return 2
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "General"
        case 1:
            return "Video"
        case 2:
            return "Audio"
        default:
            return ""
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.resuseIdentifier) ?? UITableViewCell()

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Default Name: "
                
            default:
                cell.textLabel?.text = ""
            }
            
            
        case 1:
            cell.textLabel?.text = "Video"
        case 2:
            cell.textLabel?.text = "Audio"
        default:
            print("Invalid indexpath")
        }

        return cell
    }
}
