//
//  MeetingViewController.swift
//  HMSVideo
//
//  Copyright (c) 2020 100ms. All rights reserved.
//

import UIKit

final class MeetingViewController: UIViewController {

    // MARK: - View Properties

    var user: String!
    var roomName: String!
    var flow: MeetingFlow!

    private var viewModel: MeetingViewModel!

    @IBOutlet weak var roomNameLabel: UILabel! {
        didSet {
            if flow != .join {
                roomNameLabel.text = roomName
            }
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!

    private weak var notificationObserver: NSObjectProtocol?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.isIdleTimerDisabled = true

        viewModel = MeetingViewModel(self.user, self.roomName, collectionView)

        handleError()
    }

    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent {
            UIApplication.shared.isIdleTimerDisabled = false
            viewModel.cleanup()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Action Handlers

    func handleError() {
        notificationObserver = NotificationCenter.default.addObserver(forName: Constants.hmsError,
                                                                      object: nil,
                                                                      queue: .main) { [weak self] notification in

            let message = notification.userInfo?["error"] as? String ?? "Client Error!"

            print("Error: ", message)

            let alertController = UIAlertController(title: "Error",
                                                    message: message,
                                                    preferredStyle: .alert)

            alertController.addAction(UIAlertAction(title: "OK", style: .default))

            self?.present(alertController, animated: true, completion: nil)
        }
    }

    @IBAction func switchLayoutTapped(_ sender: UIButton) {

        sender.isSelected = !sender.isSelected

        switch viewModel.layout {
        case .grid:
            viewModel.layout = .portrait
        case .portrait:
            viewModel.layout = .grid
        }
    }

    @IBAction func volumeTapped(_ sender: UIButton) {
    }

    @IBAction func switchCameraTapped(_ sender: UIButton) {
        viewModel.switchCamera()
    }

    @IBAction func editSettingsTapped(_ sender: UIButton) {

        guard let viewController = UIStoryboard(name: Constants.settings, bundle: nil)
                .instantiateInitialViewController() as? SettingsViewController
        else {
            return
        }

        present(viewController, animated: true)
    }

    @IBAction func videoTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        viewModel.switchVideo(isOn: sender.isSelected)
    }

    @IBAction func micTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        viewModel.switchAudio(isOn: sender.isSelected)
    }

    @IBAction func chatTapped(_ sender: UIButton) {
        guard let viewController = UIStoryboard(name: Constants.chat, bundle: nil)
                .instantiateInitialViewController() as? ChatViewController else {
            return
        }

        present(viewController, animated: true)
    }

    @IBAction func disconnectTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Exit Call",
                                                message: nil,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "YES", style: .destructive) { (_) in
            self.navigationController?.popViewController(animated: true)
        })

        alertController.addAction(UIAlertAction(title: "NO", style: .cancel))

        self.present(alertController, animated: true, completion: nil)

    }
}
