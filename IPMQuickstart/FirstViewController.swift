//
//  FirstViewController.swift
//  CodasApp
//
//  Created by Samone on 7/24/16.
//  Copyright © 2016 Twilio. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameTextField.delegate = self
        
    }
    func textFieldShouldReturn(nameTextField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        view.endEditing(true)
        let dvc = segue.destinationViewController as! ViewController
        dvc.data = nameTextField.text!
    }

}