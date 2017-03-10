//
//  SecondViewController.swift
//  CAlert
//
//  Created by William Chang on 17/3/10.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import ZWAlertController

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        CAlert.getInstance().showAlert("Hello!", subTitle: "What's your name?", style: .success)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
