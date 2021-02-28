//
//  SettingsViewController.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 27/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    let defaultVideoSource = ["Front Facing", "Rear Facing"]
    let videoCodecs = ["H264", "VP8", "VP9"]
    let videoResolution = ["QVGA", "VGA", "QHD", "HD", "Full HD"]
    let videoBitRate = ["Lowest (100 kbps)", "Low (256 kbps)", "Medium (512 kbps)", "High (1 mbps)", "LAN (4 mbps)"]

    @IBOutlet weak var videoSourcePicker: UIPickerView!

    @IBOutlet weak var videoCodecPicker: UIPickerView!

    @IBOutlet weak var videoResolutionPicker: UIPickerView!

    @IBOutlet weak var videoBitRatePicker: UIPickerView!

    
    @IBOutlet weak var defaultNameField: UITextField!
    
    @IBOutlet weak var publishVideoSwitch: UISwitch!
    
    @IBOutlet weak var publishAudioSwitch: UISwitch!
    
    @IBOutlet weak var maximumRowsSwitch: UITextField!
    
    @IBOutlet weak var audioPollDelayField: UITextField!
    
    @IBOutlet weak var silenceThresholdField: UITextField!
    
    @IBOutlet weak var mirrorMyVideoSwitch: UISwitch!
    
    @IBOutlet weak var showVideoPreviewSwitch: UISwitch!
    
    @IBOutlet weak var videoFrameRateField: UITextField!
    
    @IBOutlet weak var environmentField: UITextField! {
        didSet {
            print(environmentField.text ?? "nil")
        }
    }
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPickers()
    }

    // MARK: - View Modifiers

    func setupPickers() {
        videoCodecPicker.selectRow(1, inComponent: 0, animated: false)
        videoResolutionPicker.selectRow(2, inComponent: 0, animated: false)
        videoBitRatePicker.selectRow(2, inComponent: 0, animated: false)
    }

    // MARK: - Action Handlers

    @IBAction func closeTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

extension SettingsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0:
            return defaultVideoSource.count
        case 1:
            return videoCodecs.count
        case 2:
            return videoResolution.count
        case 3:
            return videoBitRate.count
        default:
            return 0
        }
    }
}

extension SettingsViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        switch pickerView.tag {
        case 0:
            return defaultVideoSource[row]
        case 1:
            return videoCodecs[row]
        case 2:
            return videoResolution[row]
        case 3:
            return videoBitRate[row]
        default:
            return ""
        }
    }
}
