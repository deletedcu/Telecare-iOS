//
//  ViewController.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 9/21/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var email: UITextField!

    @IBOutlet weak var password: UITextField!
    
    @IBAction func login(_ sender: AnyObject) {
        let username = email.text
        let pass = password.text
        
        // Refactor later
        
        print(username!)
        print(pass!)
        
        let passcombination = username! + ":" + pass!
        
        let headers: HTTPHeaders = [
            "Authorization": "Basic " + passcombination.toBase64(),
            "Accept": "application/json"
        ]
        
        
        Alamofire.request("http://dev-telecarelive.pantheonsite.io/api/v1/auth", headers: headers)
            .responseJSON{ response in
//                debugPrint(response)
                let json = JSON(data: response.data!)
                
                debugPrint(json)
                
                let alert = UIAlertView()
                alert.title = "Alert"
                alert.message = json["sid"].string
                alert.addButton(withTitle: "Ok")
                alert.show()
                
                let keychain = KeychainSwift()
                keychain.set(username!, forKey: "username")
                keychain.set(json["sid"].string!, forKey: "sid")
                
                print(keychain.get("sid"))
                print(keychain.get("username"))
            }
        
        
    }
    
    @IBAction func register(_ sender: AnyObject) {
    }
    
    
    @IBAction func forgotPassword(_ sender: AnyObject) {
    }
    
}

extension String
{
    func fromBase64() -> String
    {
        let data = NSData(base64Encoded: self, options: NSData.Base64DecodingOptions(rawValue: 0))
        return String(data: data! as Data, encoding: String.Encoding.utf8)!
    }
    
    func toBase64() -> String
    {
        let data = self.data(using: String.Encoding.utf8)
        return data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }
}

