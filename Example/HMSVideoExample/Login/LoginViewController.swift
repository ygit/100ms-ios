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

    @IBOutlet weak var joinMeetingIDField: UITextField! {
        didSet {
            Utilities.drawCorner(on: joinMeetingIDField)
        }
    }
    
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

    @IBOutlet weak var publishVideoButton: UIButton! {
        didSet {
            UserDefaults.standard.set(false, forKey: Constants.publishVideo)
        }
    }

    @IBOutlet weak var publishAudioButton: UIButton! {
        didSet {
            UserDefaults.standard.set(false, forKey: Constants.publishAudio)
        }
    }

    @IBOutlet weak var cameraPreview: UIView!

    var session: AVCaptureSession?
    var input: AVCaptureDeviceInput?
    var output: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCameraPreview()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {

        super.willTransition(to: newCollection, with: coordinator)

        coordinator.animate { _ in
            self.updateCameraView()
        }
    }

    // MARK: - View Modifiers

    func setupCameraPreview() {

        session = AVCaptureSession()
        output = AVCapturePhotoOutput()
        if let camera = getDevice(position: .front) {
            do {
                input = try AVCaptureDeviceInput(device: camera)
            } catch let error as NSError {
                print(error)
                input = nil
            }

            guard let input = input, let output = output, let session = session else { return }

            if session.canAddInput(input) {
                session.addInput(input)

                if session.canAddOutput(output) {
                    session.addOutput(output)
                }

                let settings = AVCapturePhotoSettings()
                let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!

                let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                                     kCVPixelBufferWidthKey as String: self.view.frame.size.width,
                                     kCVPixelBufferHeightKey as String: self.view.frame.size.height] as [String: Any]
                settings.previewPhotoFormat = previewFormat

                output.capturePhoto(with: settings, delegate: self)
            }
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        cameraPreview.addGestureRecognizer(tap)
    }

    func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices()
        for de in devices {
            let deviceConverted = de
            if deviceConverted.position == position {
                return deviceConverted
            }
        }
        return nil
    }
    
    func updateCameraView() {
        let orientation = UIApplication.shared.statusBarOrientation
        previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) ?? .portrait
        previewLayer?.frame = cameraPreview.bounds
    }

    // MARK: - Action Handlers
    
    @objc func dismissKeyboard(_ sender: Any) {
        joinMeetingIDField.resignFirstResponder()
    }

    @IBAction func cameraTapped(_ sender: UIButton) {

        sender.isSelected = !sender.isSelected
        UserDefaults.standard.set(sender.isEnabled, forKey: Constants.publishVideo)

        if let session = session {
            if sender.isSelected {
                if session.isRunning {
                    session.stopRunning()
                    previewLayer?.removeFromSuperlayer()
                }
            } else {
                if !session.isRunning {
                    session.startRunning()
                    cameraPreview.layer.addSublayer(previewLayer!)
                }
            }
        }
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
        var message: String?
        
        if flow == .join {
            title = "Join a Meeting"
            message = "Enter your Name"
        } else {
            title = "Start a Meeting"
        }

        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Enter your Name"
            textField.clearButtonMode = .always
            textField.text = UserDefaults.standard.string(forKey: Constants.defaultName) ?? "iOS User"
        }

        if flow == .start {
            alertController.addTextField { textField in
                textField.placeholder = "Enter Room Name"
                textField.clearButtonMode = .always
                textField.text = "My Meeting"
            }
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Submit", style: .default) { [weak self] _ in
            
            var room: String
            
            if flow == .join {
                if !(self?.joinMeetingIDField.text!.isEmpty)! {
                    room = (self?.joinMeetingIDField.text!)!
                } else {
                    self?.showErrorAlert(with: "Enter Meeting ID!")
                    return
                }
            } else {
                if !(alertController.textFields?[1].text!.isEmpty)! {
                    room = (alertController.textFields?[1].text!)!
                } else {
                    self?.showErrorAlert(with: "Enter Meeting Name!")
                    return
                }
            }

            guard let name = alertController.textFields?[0].text, !name.isEmpty,
                  let viewController = UIStoryboard(name: Constants.meeting, bundle: nil)
                    .instantiateInitialViewController() as? MeetingViewController
            else {
                self?.dismiss(animated: true)
                let message = flow == .join ? "Could not join meeting" : "Could not start meeting"
                self?.showErrorAlert(with: message)
                return
            }

            viewController.user = name
            viewController.flow = flow            
            viewController.roomName = room

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

@available(iOS 11.0, *)
extension LoginViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {

        if let session = session {
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer?.videoGravity = .resizeAspectFill
            updateCameraView()
            cameraPreview.layer.addSublayer(previewLayer!)
            session.startRunning()
        }
    }
}
