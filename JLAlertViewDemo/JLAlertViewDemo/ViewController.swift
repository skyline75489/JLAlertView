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

    override func viewDidLoad() {
        super.viewDidLoad()

        alertButton.addTarget(self, action: #selector(showAlert), forControlEvents: .TouchUpInside)

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showAlert() {
        JLAlertView(title: "Default Style", message: "Standart Alert")
            .addButttonWithTitle("Cancel", style: .Cancel, action: nil)
            .addButttonWithTitle("OK", action: nil)
            .show()

    }

}

