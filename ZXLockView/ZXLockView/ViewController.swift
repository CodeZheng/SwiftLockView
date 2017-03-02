//
//  ViewController.swift
//  ZXLockView
//
//  Created by admin on 28/02/2017.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func setPassword(_ sender: UIButton) {
        let passwordVC = PasswordViewController(nibName: nil, bundle: nil)
        passwordVC.lockViewType = ZXLockView.LockViewType.set
        passwordVC.labelTT = "请绘制手势密码"
        self.present(passwordVC, animated: true, completion: nil)
    }

    @IBAction func changePassword(_ sender: UIButton) {
        let passwordVC = PasswordViewController(nibName: nil, bundle: nil)
        passwordVC.lockViewType = ZXLockView.LockViewType.change
        passwordVC.labelTT = "请绘制原手势密码"
        self.present(passwordVC, animated: true, completion: nil)
    }
    
    @IBAction func testPassword(_ sender: UIButton) {
        let passwordVC = PasswordViewController(nibName: nil, bundle: nil)
        passwordVC.lockViewType = ZXLockView.LockViewType.test
        passwordVC.labelTT = "请绘制原手势密码"
        self.present(passwordVC, animated: true, completion: nil)
    }
}

