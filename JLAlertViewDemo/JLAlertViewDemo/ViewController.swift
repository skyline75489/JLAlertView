//
//  ViewController.swift
//  JLAlertViewDemo
//
//  Created by skyline on 16/4/5.
//  Copyright © 2016年 skyline. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var alertButton: UIButton!
    @IBOutlet weak var textfieldAlertButton: UIButton!
    @IBOutlet weak var imageAlertButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        alertButton.addTarget(self, action: #selector(showSimpleAlert), for: .touchUpInside)
        textfieldAlertButton.addTarget(self, action: #selector(showTextFieldAlert), for: .touchUpInside)
        imageAlertButton.addTarget(self, action: #selector(showImageAlert), for: .touchUpInside)
    }

    func showSimpleAlert() {
        JLAlertView(title: "Default Style", message: "Standard Alert")
        .addButttonWithTitle("Cancel", style: .cancel, action: nil)
        .addButttonWithTitle("OK", action:nil)
        .show()
    }

    func showTextFieldAlert() {
        JLAlertView(title: "Default Style", message: "Standard Alert")
        .addTextFieldWithConfigurationHandler({ (textField) in
            textField.placeholder = "Username"
        })
        .addTextFieldWithConfigurationHandler({ (textField) in
            textField.placeholder = "Password"
        })
        .addButttonWithTitle("Cancel", style: .cancel, action: nil)
        .addButttonWithTitle("OK", action:{(title, alert) in
            let username = alert.textFields[0].text
            let password = alert.textFields[1].text
            print(username)
            print(password)
        })
        .show()
    }

    func showImageAlert() {
        JLAlertView(title: "Default Style", message: "Standard Alert")
        .addImage(UIImage(named: "ios-announce")!)
        .addButttonWithTitle("Cancel", style: .cancel, action: nil)
        .addButttonWithTitle("OK", action:nil)
        .show()
    }
}

