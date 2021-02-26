//
//  MeetingViewModel.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation

final class MeetingViewModel {
    
    private(set) var wrapper: HMSWrapper
    
    
    
    // MARK: - Initializers
    
    
    init(endpoint: String, token: String, user: String, room: String) {
        
        wrapper = HMSWrapper(endpoint: endpoint, token: token, user: user, roomName: room)
        
        wrapper.fetchToken { [weak self] (token, error) in
            
            if let token = token {
                self?.wrapper.connect(with: token) {
                    //TODO: update UI
                }
            } else {
                //TODO: show alert
            }
        }
    }
    
    
    // MARK: - View Modifiers
    
    
    // MARK: - Action Handlers
    
    

    
}
