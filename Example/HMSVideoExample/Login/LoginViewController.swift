//
//  LoginViewController.swift
//  HMSVideo
//
//  Copyright (c) 2020 100ms. All rights reserved.
//

import UIKit
import AVKit

final class LoginViewController: UIViewController {

    // MARK: - View Properties

    @IBOutlet weak var joinMeetingStackView: UIStackView! {
        didSet {
            Utilities.drawCorner(on: joinMeetingStackView)
        }
    }

    @IBOutlet weak var startMeetingStackView: UIStackView! {
        didSet {
            Utilities.drawCorner(on: startMeetingStackView)
        }
    }

    @IBOutlet weak var joinMeetingButton: UIButton! {
        didSet {
            Utilities.drawCorner(on: joinMeetingButton)
        }
    }

    @IBOutlet private weak var startMeetingButton: UIButton! {
        didSet {
            Utilities.drawCorner(on: startMeetingButton)
        }
    }
    
    @IBOutlet weak var cameraPreview: UIView!
    
    var session: AVCaptureSession?
    var input: AVCaptureDeviceInput?
    var output: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?

    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialize session an output variables this is necessary
        session = AVCaptureSession()
        output = AVCaptureStillImageOutput()
        if let camera = getDevice(position: .front) {
            do {
                input = try AVCaptureDeviceInput(device: camera)
            } catch let error as NSError {
                print(error)
                input = nil
            }
            
            guard let input = input, let output = output, let session = session else { return }
            
            if(session.canAddInput(input) == true){
                session.addInput(input)
                output.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
                if(session.canAddOutput(output) == true){
                    session.addOutput(output)
                    previewLayer = AVCaptureVideoPreviewLayer(session: session)
                    previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                    previewLayer?.frame = cameraPreview.bounds
                    cameraPreview.layer.addSublayer(previewLayer!)
                    session.startRunning()
                }
            }
        }
    }
    //Get the device (Front or Back)
    func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices();
        for de in devices {
            let deviceConverted = de
            if(deviceConverted.position == position){
                return deviceConverted
            }
        }
        return nil
    }
    
    
    // MARK: - Action Handlers

    @IBAction func cameraTapped(_ sender: UIButton) {
        AVCaptureDevice.requestAccess(for: .video) { _ in }
        sender.isSelected = !sender.isSelected
        UserDefaults.standard.set(sender.isEnabled, forKey: Constants.publishVideo)
    }

    @IBAction func micTapped(_ sender: UIButton) {
        AVAudioSession.sharedInstance().requestRecordPermission { _ in }
        sender.isSelected = !sender.isSelected
        UserDefaults.standard.set(sender.isEnabled, forKey: Constants.publishAudio)
    }

    @IBAction private  func startMeetingTapped(_ sender: UIButton) {
        showInputAlert(flow: sender.tag == 0 ? .join : .start)
    }

    func showInputAlert(flow: MeetingFlow) {

        let title: String
        let roomPlaceholder: String

        if flow == .join {
            title = "Join a Meeting"
            roomPlaceholder = "Enter Room ID"
        } else {
            title = "Start a Meeting"
            roomPlaceholder = "Enter Room Name"
        }

        let alertController = UIAlertController(title: title,
                                                message: nil,
                                                preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.placeholder = "Enter your Name"
            textField.text = UserDefaults.standard.string(forKey: Constants.defaultName) ?? "iOS User"
        }

        alertController.addTextField { textField in
            textField.placeholder = roomPlaceholder
            if flow == .join {
                textField.text = UserDefaults.standard.string(forKey: Constants.roomName) ?? "6033b4cb89a96e73b23d13dc"
            } else {
                textField.text = "My Meeting"
            }
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Submit", style: .default) { [weak self] _ in

            guard let name = alertController.textFields?[0].text, !name.isEmpty,
                  let room = alertController.textFields?[1].text, !room.isEmpty,
                  let viewController = UIStoryboard(name: Constants.meeting, bundle: nil)
                            .instantiateInitialViewController() as? MeetingViewController
            else {
                self?.dismiss(animated: true)
                let message = flow == .join ? "Could not join meeting" : "Could not start meeting"
                self?.showErrorAlert(with: message)
                return
            }

            viewController.user = name
            viewController.roomName = room
            viewController.flow = flow

            self?.save(name, room)

            self?.navigationController?.pushViewController(viewController, animated: true)
        })

        present(alertController, animated: true, completion: nil)
    }

    func showErrorAlert(with message: String) {
        let alertController = UIAlertController(title: "Alert",
                                                message: message,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .default))

        present(alertController, animated: true, completion: nil)
    }

    func save(_ name: String, _ room: String, _ meeting: String? = nil) {
        let userDefaults = UserDefaults.standard

        userDefaults.set(name, forKey: Constants.defaultName)
        userDefaults.set(room, forKey: Constants.roomName)

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
