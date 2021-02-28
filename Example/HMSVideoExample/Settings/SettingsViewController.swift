//
//  SettingsViewController.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 27/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Action Handlers

    @IBAction func closeTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
