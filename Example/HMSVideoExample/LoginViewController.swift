//
//  LoginViewController.swift
//  HMSVideo
//
//  Copyright (c) 2020 100ms. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var roomNameField: UITextField!
    @IBOutlet weak var userNameField: UITextField!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        addNavBarImage()
        
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification,
                                               object: nil,
                                               queue: .main) { (notification) in
            self.addNavBarImage()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIDevice.orientationDidChangeNotification,
                                                  object: nil)
    }
    
    
    // MARK: - View Modifiers
    
    func addNavBarImage() {
        let navController = navigationController!
        
        let image = UIImage(named: "HMS.png")
        
        let label = UILabel()
        label.text = "100ms"
        label.font = .preferredFont(forTextStyle: .title1)
        label.sizeToFit()
        label.frame = CGRect(x: navController.navigationBar.frame.size.width/2 - label.frame.size.width/2, y: navController.navigationBar.frame.size.height/2 - label.frame.size.height/2, width: label.frame.size.width, height: label.frame.size.height)
        
        
        let imageView = UIImageView(image: image)
        let height = navController.navigationBar.frame.height
        
        imageView.frame = CGRect(x: label.frame.origin.x - height, y: 0, width: height, height: height)
        imageView.contentMode = .scaleAspectFit
        
        let view = UIView()
        view.addSubview(label)
        view.addSubview(imageView)
        view.frame = navController.navigationBar.bounds
        
        navigationItem.titleView = view
    }
    
    
    // MARK: - Action Handlers
    
    @IBAction func loginPressed(_ sender: Any) {
        guard let roomName = roomNameField.text, let userName = userNameField.text, !userName.isEmpty, !roomName.isEmpty else {
            let alertController = UIAlertController(title: "Alert", message: "Please fill in all fields.", preferredStyle: .alert)
            
            let action1 = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(action1)
            self.present(alertController, animated: true, completion: nil)
            
            return;
        }
        
        guard let meetingController = UIStoryboard(name: "Meeting", bundle: nil).instantiateInitialViewController() as? MeetingViewController else {
            return
        }
        
        meetingController.roomName = roomName
        meetingController.userName = userName
        navigationController?.pushViewController(meetingController, animated: true)
    }
}
