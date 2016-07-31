//
//  ViewController.swift
//  IPMQuickstart
//

import UIKit
// I had a template show me how to bounce info between the server and the app. Most of the comments are explaining what the functions do
class ViewController: UIViewController {
  
  var client: TwilioIPMessagingClient? = nil
  var generalChannel: TWMChannel? = nil
  var identity = ""
  var messages: [TWMMessage] = []
  // Stuff for data transfer and my own encryptor + decryptor
  var data = ""
  var encryptedString = ""
  var encryptor = [
        "0" : "0",
        "1" : "1",
        "2" : "2",
        "3" : "3",
        "4" : "4",
        "5" : "5",
        "6" : "6",
        "7" : "7",
        "8" : "8",
        "9" : "9",
        "!" : "!",
        "?" : "?",
        "a" : "0",
        "b" : "1",
        "c" : "2",
        "d" : "3",
        "e" : "4",
        "f" : "5",
        "g" : "6",
        "h" : "7",
        "i" : "8",
        "j" : "9",
        "k" : "`",
        "l" : ";",
        "m" : "@",
        "n" : "#",
        "o" : "$",
        "p" : "%",
        "q" : "^",
        "r" : "&",
        "s" : "*",
        "t" : "(",
        "u" : ")",
        "v" : "_",
        "w" : "+",
        "x" : "|",
        "y" : "}",
        "z" : "{",
        " " : ":",
        "," : ".",
    "A" : "a",
    "B" : "b",
    "C" : "c",
    "D" : "d",
    "E" : "e",
    "F" : "f",
    "G" : "g",
    "H" : "h",
    "I" : "i",
    "J" : "j",
    "K" : "k",
    "L" : "l",
    "M" : "m",
    "N" : "n",
    "O" : "o",
    "P" : "p",
    "Q" : "q",
    "R" : "r",
    "S" : "s",
    "T" : "t",
    "U" : "U",
    "V" : "v",
    "W" : "w",
    "X" : "x",
    "Y" : "y",
    "Z" : "z",
    ]
    var decryptor = [
        "0" : "a",
        "1" : "b" ,
        "2" : "c",
        "3" : "d",
        "4" : "e",
        "5" : "f",
        "6" : "g",
        "7" : "h",
        "8" : "i",
        "9" : "j",
        "`" : "k",
        ";" : "l",
        "@" : "m",
        "#" : "n",
        "$" : "o",
        "%" : "p",
        "^" : "q",
        "&" : "r",
        "*" : "s",
        "(" : "t",
        ")" : "u",
        "_" : "v",
        "+" : "w",
        "|" : "x",
        "}" : "y",
        "{" : "z",
        ":" : " ",
        "." : ",",
    "a" : "A",
    "b" : "B",
    "c" : "C",
    "d" : "D",
    "e" : "E",
    "f" : "F",
    "g" : "G",
    "h" : "H",
    "i" : "I",
    "j" : "J",
    "k" : "K",
    "l" : "L",
    "m" : "M",
    "n" : "N",
    "o" : "O",
    "p" : "P",
    "q" : "Q",
    "r" : "R",
    "s" : "S",
    "t" : "T",
    "u" : "U",
    "v" : "V",
    "w" : "W",
    "x" : "X",
    "y" : "Y",
    "z" : "Z",
    
        
    ]
    
  
  // UI controls
@IBOutlet weak var bottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var nameLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    nameLabel.text = data + "'s chat"
    
    // Gets the access token for the server, which I have to run first
    let deviceId = UIDevice.currentDevice().identifierForVendor!.UUIDString
    let urlString = "http://localhost:8000/token.php?device=\(deviceId)"
    
    // Get JSON from server, or Java Script Object Notation, for transmitting data from the web
    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    let session = NSURLSession(configuration: config, delegate: nil, delegateQueue: nil)
    let url = NSURL(string: urlString)
    let request  = NSMutableURLRequest(URL: url!)
    request.HTTPMethod = "GET"
    
    // Make HTTP request
    session.dataTaskWithRequest(request, completionHandler: { data, response, error in
      if (data != nil) {
        // Go through result JSON
        let json = JSON(data: data!)
        let token = json["token"].stringValue
        self.identity = json["identity"].stringValue
        // Set up Twilio IPM client
        let accessManager = TwilioAccessManager.init(token: token, delegate: nil)
        self.client = TwilioIPMessagingClient.ipMessagingClientWithAccessManager(accessManager, properties: nil, delegate: self)
        
        // Update UI on main thread
        dispatch_async(dispatch_get_main_queue()) {
          self.navigationItem.prompt = "Logged in as \"\(self.identity)\""
        }
      } else {
        print("Error fetching token :\(error)")
      }
    }).resume()
    
    // Look for keyboard events and animate text field as necessary
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: #selector(ViewController.keyboardWillShow(_:)),
      name:UIKeyboardWillShowNotification,
      object: nil);
    
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: #selector(ViewController.keyboardDidShow(_:)),
      name:UIKeyboardDidShowNotification,
      object: nil);
    
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: #selector(ViewController.keyboardWillHide(_:)),
      name:UIKeyboardWillHideNotification,
      object: nil);
    
    // Set up UI controls
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 66.0
    self.tableView.separatorStyle = .None
  }
  
  // Keyboard Animation Logic
  
  func keyboardWillShow(notification: NSNotification) {
    let keyboardHeight = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.height
    UIView.animateWithDuration(0.1, animations: { () -> Void in
      self.bottomConstraint.constant = keyboardHeight! + 10
      self.view.layoutIfNeeded()
    })
  }
  
  func keyboardDidShow(notification: NSNotification) {
    self.scrollToBottomMessage()
  }
  
  func keyboardWillHide(notification: NSNotification) {
    UIView.animateWithDuration(0.1, animations: { () -> Void in
      self.bottomConstraint.constant = 20
      self.view.layoutIfNeeded()
    })
  }
  
  // More UI Logic
  
  // Dismiss keyboard if view is tapped
  @IBAction func viewTapped(sender: AnyObject) {
    self.textField.resignFirstResponder()
  }
  
  // Scroll to bottom of table view for messages
  func scrollToBottomMessage() {
    if self.messages.count == 0 {
      return
    }
    let bottomMessageIndex = NSIndexPath(forRow: self.tableView.numberOfRowsInSection(0) - 1,
      inSection: 0)
    self.tableView.scrollToRowAtIndexPath(bottomMessageIndex, atScrollPosition: .Bottom,
      animated: true)
  }

}

// Twilio IP Messaging Delegate
extension ViewController: TwilioIPMessagingClientDelegate {
  func ipMessagingClient(client: TwilioIPMessagingClient!, synchronizationStatusChanged status: TWMClientSynchronizationStatus) {
    if status == .Completed {
      // Join (or create) the general channel
      let defaultChannel = "general"
      
      self.generalChannel = client.channelsList().channelWithUniqueName(defaultChannel)
      if let generalChannel = self.generalChannel {
        generalChannel.joinWithCompletion({ result in
          print("Channel joined with result \(result)")
        })
      } else {
        // Create the general channel if it hasn't been created yet
        client.channelsList().createChannelWithOptions([TWMChannelOptionFriendlyName: "General Chat Channel", TWMChannelOptionType: TWMChannelType.Public.rawValue], completion: { (result, channel) -> Void in
          if result.isSuccessful() {
            self.generalChannel = channel
            self.generalChannel?.joinWithCompletion({ result in
              self.generalChannel?.setUniqueName(defaultChannel, completion: { result in
                print("channel unqiue name set")
              })
            })
          }
        })
      }
    }
  }
  
  // Called whenever a channel we've joined receives a new message
  func ipMessagingClient(client: TwilioIPMessagingClient!, channel: TWMChannel!,
    messageAdded message: TWMMessage!) {
      self.messages.append(message)
      self.tableView.reloadData()
      dispatch_async(dispatch_get_main_queue()) {
        if self.messages.count > 0 {
          self.scrollToBottomMessage()
        }
      }
  }
}

// UITextField Delegate, and my encryption loop
extension ViewController: UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    for character in textField.text!.characters{
       let characterValue = encryptor["\(character)"]
        encryptedString += "\(characterValue!)"
    }
    var encryptedTextField = (encryptedString)
    let msg = self.generalChannel?.messages.createMessageWithBody(encryptedTextField)
    self.generalChannel?.messages.sendMessage(msg) { result in
      
      textField.resignFirstResponder()
    
    }
    return true
    }
    @IBAction func decodeButton(sender: UIButton) {
        for character in encryptedString.characters{
            let characterValue = decryptor["\(character)"]
            textField.text = ""
            encryptedString += "\(characterValue!)"
        }
        var decryptedTextField = (encryptedString)
        
        let msg2 = self.generalChannel?.messages.createMessageWithBody(decryptedTextField)
        self.generalChannel?.messages.sendMessage(msg2) { result in
            self.textField.text = ""
            self.encryptedString = ""
            self.textField.resignFirstResponder()
    }
    self.encryptedString = ""
    }
    }


  
   




// UITableView Delegate
extension ViewController: UITableViewDelegate {
  
    // Return number of rows in the table
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.messages.count
  }
  
  // Create table view rows
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
    -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath)
      let message = self.messages[indexPath.row]
      
      // Set table cell values
      cell.detailTextLabel?.text = message.author
      cell.textLabel?.text = message.body
      cell.selectionStyle = .None
      return cell
  }

}
// UITableViewDataSource Delegate
extension ViewController: UITableViewDataSource {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }


}

