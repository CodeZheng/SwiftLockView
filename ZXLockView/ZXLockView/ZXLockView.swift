//
//  ZXLockView.swift
//  ZXLockView
//
//  Created by admin on 28/02/2017.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit

protocol DismissLockViewDelegate {
    func successLockAndBack()
    func showAlertController(message: String)
    func setNewPassword(message: String)
}

class ZXLockView: UIView {
    
    enum LockViewType {
        case set
        case change
        case test
    }

    var delegate : DismissLockViewDelegate?
    var lockViewType : LockViewType?
    var allButtons = [UIButton]()
    var selectedButtons = [UIButton]()
    var selectedBtnTags = [Int]()
    fileprivate lazy var titleLabel : UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        return titleLabel
    }()
    
    let screenW = UIScreen.main.bounds.size.width
    let screenH = UIScreen.main.bounds.size.height
    var passwordSetCount = 0
    let passwordKey = "pwdArr"
    var defaultCount = 5
    fileprivate lazy var timer : Timer = {
       let timer = Timer(timeInterval: 1.0, target: self, selector: #selector(timeWith60s), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .commonModes)
        return timer
    }()
    var time = 60
    
    init(frame: CGRect, delegate: DismissLockViewDelegate, lockViewType: LockViewType, title: String) {
        super.init(frame: frame)
        self.delegate = delegate
        self.lockViewType = lockViewType
        setupUI()
//        titleLabel.backgroundColor = UIColor.red
        titleLabel.text = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.timer.invalidate()
    }
    
    
    //MARK:- 重绘
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        var count = 0
        for btn in selectedButtons {
            if count == 0 {
                path.move(to: btn.center)
            }else {
                path.addLine(to: btn.center)
            }
            count += 1
        }
        UIColor.red.set()
        path.lineWidth = 5
        path.lineJoinStyle = .round
        path.stroke()
    }

}

//MARK:- 获取手势密码轨迹
extension ZXLockView {
    func isButtonInPosition(position: CGPoint) -> UIButton? {
        for btn in allButtons {
            if btn.frame.contains(position) {
             return btn
            }
        }
        
        return nil
    }
    
    func getPasswrdFromSelectedBtnTags() {
        if selectedBtnTags.count != 0 {
            selectedBtnTags.removeAll()
        }
        for btn in selectedButtons {
            selectedBtnTags.append(btn.tag)
        }
        print(selectedButtons.count)
        print(selectedBtnTags)
    }
    
    func isExistInSelectedBtns(btn: UIButton) -> Bool {
        return selectedButtons.contains(btn) ? true : false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let position = touch?.location(in: self)
        guard let pn = position else {
            return
        }
        let btn = isButtonInPosition(position: pn)
        if (btn != nil) {
            btn?.isSelected = true
            self.selectedButtons.removeAll()
            self.selectedButtons.append(btn!)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let position = touch?.location(in: self)
        guard let pn = position else {
            return
        }
        let btn = isButtonInPosition(position: pn)
        guard let button = btn else {
            return
        }
        if btn != nil && !isExistInSelectedBtns(btn: button){
            button.isSelected = true
            self.selectedButtons.append(button)
        }
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        getPasswrdFromSelectedBtnTags()
        guard let lockViewType = lockViewType else {
            return
        }
        passwordSetCount += 1
        switch lockViewType {
        case .set:
            setPassword()
        case .change:
            changePassword()
        case .test:
            testPassword()
        }
        for btn in allButtons {
            btn.isSelected = false
        }
        
        self.selectedButtons.removeAll()
        
        setNeedsDisplay()
    }
    
}

extension ZXLockView {
    func setPassword() {
        if passwordSetCount == 1 {
            let pwdArr = selectedBtnTags
            UserDefaults.standard.setValue(pwdArr, forKey: passwordKey)
            titleLabel.text = "请再次绘制手势密码"
        }else if passwordSetCount == 2 {
            if firstPasswordIsEqualToSecond(firstArr: UserDefaults.standard.value(forKey: passwordKey) as! [Int], secondArr: selectedBtnTags) {
                titleLabel.text = "设置密码成功"
                delegate?.successLockAndBack()
            }else {
                delegate?.showAlertController(message: "两次输入密码不一致，请重新输入")
                selectedBtnTags.removeAll()
                UserDefaults.standard.removeObject(forKey: passwordKey)
                titleLabel.text = "请再次绘制手势密码"
                passwordSetCount = 0
            }
        }
    }
    
    func changePassword() {
        let pwdArr = UserDefaults.standard.value(forKey: passwordKey) as? [Int]
        
        if passwordSetCount == 1 {
            if (pwdArr == nil) {
                delegate?.setNewPassword(message: "请先设置密码")
            }else {
                if firstPasswordIsEqualToSecond(firstArr: pwdArr!, secondArr: selectedBtnTags) {
                    titleLabel.text = "请绘制新手势密码"
                }else {
                    delegate?.showAlertController(message: "原手势密码不正确")
                    titleLabel.text = "请绘制原手势密码"
                    passwordSetCount = 0
                }
            }
        }else if passwordSetCount == 2 {
            let pwdArr = selectedBtnTags
            UserDefaults.standard.setValue(pwdArr, forKey: passwordKey)
            titleLabel.text = "请再次绘制手势密码"
        }else if passwordSetCount == 3 {
            if firstPasswordIsEqualToSecond(firstArr: pwdArr!, secondArr: selectedBtnTags) {
                titleLabel.text = "修改密码成功"
                delegate?.successLockAndBack()
            }else {
                delegate?.showAlertController(message: "两次输入密码不一致，请重新输入")
                selectedBtnTags.removeAll()
                UserDefaults.standard.removeObject(forKey: passwordKey)
                titleLabel.text = "请再次绘制手势密码"
                passwordSetCount = 1
            }
        }
    }
    
    func testPassword() {
        if passwordSetCount < defaultCount {
            let pwdArr = UserDefaults.standard.value(forKey: passwordKey) as! [Int]
            if firstPasswordIsEqualToSecond(firstArr: pwdArr, secondArr: selectedBtnTags) {
                delegate?.successLockAndBack()
            }else  {
               titleLabel.text = "密码错误，还有\(defaultCount-passwordSetCount)次机会"
            }
        }
        if defaultCount == passwordSetCount {
            self.timer.fireDate = .distantPast
        }
    }
    
    //MARK:- 定时器方法
    func timeWith60s() {
        titleLabel.text = "\(time)秒之后可以输入"
        self.isUserInteractionEnabled = false
        setNeedsDisplay()
        time -= 1
        if time == 0 {
            titleLabel.text = "请重新绘制手势密码"
            self.timer.fireDate = .distantFuture
            time = 60
            self.isUserInteractionEnabled = true
            passwordSetCount = 0
        }
    }

    //MARK:- 判断两次输入是否相同
    func firstPasswordIsEqualToSecond(firstArr:[Int], secondArr:[Int]) -> Bool {
        if firstArr.count == secondArr.count {
            for i in 0..<firstArr.count {
                if firstArr[i] != secondArr[i] {
                    return false
                }
            }
            return true
        }else {
            return false
        }
    }
}

//MARK:- 设置ui
extension ZXLockView {
    func setupUI() {
        let intervalW = (screenW-150)/4
        let intervalH = 50
        let Y = (screenH-150-CGFloat(3*intervalH))/2
        self.backgroundColor = UIColor(patternImage: UIImage(named: "夜空.jpeg")!)
        self.titleLabel.frame = CGRect(x: intervalW+20, y: Y-60, width: 150+2.0*intervalW-40, height: 50)
        self.addSubview(titleLabel)
        addButtonOfLock(intervalW: intervalW, intervalH: intervalH, Y: Y)
    }
    
    func addButtonOfLock(intervalW:CGFloat,intervalH:Int,Y:CGFloat) {
        var tag = 0
        for i in 0..<3 {
            for j in 0..<3 {
                let button = UIButton(type: UIButtonType.custom)
                button.isUserInteractionEnabled = false
                button.setImage(UIImage(named: "未选中"), for: .normal)
                button.setImage(UIImage(named: "选中"), for: .selected)
                button.frame = CGRect(x: intervalW+CGFloat(j)*(50+intervalW), y: Y+CGFloat(i*(50+intervalH)), width: 50, height: 50)
                button.tag = tag
                tag += 1
                self.allButtons.append(button)
                self.addSubview(button)
            }
        }
    }
}
