//
//  PasswordViewController.swift
//  ZXLockView
//
//  Created by admin on 28/02/2017.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit

class PasswordViewController: UIViewController,DismissLockViewDelegate {

    var lockViewType : ZXLockView.LockViewType?
    var labelTT : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = ZXLockView(frame: self.view.frame, delegate: self, lockViewType: self.lockViewType!, title: labelTT)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func successLockAndBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlertController(message: String) {
        let alertC = UIAlertController.init(title: "提示", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "返回", style: .cancel, handler: nil)
        alertC.addAction(alertAction)
        self.present(alertC, animated: true, completion: nil)
    }
    
    func setNewPassword(message: String) {
        let alertC = UIAlertController.init(title: "提示", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "返回", style: .cancel) { (alertAction) in
            self.dismiss(animated: true, completion: { 
                
            })
        }
        alertC.addAction(alertAction)
        self.present(alertC, animated: true, completion: nil)
    }
}
