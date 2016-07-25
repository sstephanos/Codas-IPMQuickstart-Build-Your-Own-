//
//  FrontViewController.swift
//  CodasApp
//
//  Created by Samone on 7/24/16.
//  Copyright © 2016 Twilio. All rights reserved.
//

import UIKit

class FrontViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let timer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: "timeToMoveOn", userInfo: nil, repeats: false)
    }
    func timeToMoveOn() {
        self.performSegueWithIdentifier("goToMainUI", sender: self)
        
        
    }
}
