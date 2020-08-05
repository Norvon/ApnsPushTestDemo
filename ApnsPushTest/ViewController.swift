//
//  ViewController.swift
//  ApnsPushTest
//
//  Created by nor on 2020/1/15.
//  Copyright © 2020 nor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var `switch`: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.clearButtonMode = .always
        textField.text = ""
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view .endEditing(true)
    }
    
    @IBAction func clickBtn(_ sender: Any) {
        testPush()
    }
    
    var playload : [String:Any] {
        var aps = [String:Any]()
        var alert = [String:Any]()
        var media = [String: Any]()
        
        alert["title"] = "这是标题"
        alert["subtitle"] = "这是subtitle"
        alert["body"]  = "这是一个内容"
        aps["alert"] = alert
        
        aps["sound"] = "default"
        aps["mutable-content"] = 0
        aps["category"] = "myNotificationCategory"
        
        media["type"] = "image"
        media["url"] = "https://www.baidu.com/img/bd_logo1.png"
        return ["aps": aps,
                "media": media]
    }
    
    func testPush() {
        let bundleId = "com.orangecds.CDSDesign"
        let isSanBox = !self.switch.isOn
        
        var pusher: APNsPusher? = nil
        
        if isSanBox {
            pusher = APNsPusher.devCerPusher
        } else {
            pusher = APNsPusher.cerPusher
        }

        pusher!.push(token:textField.text!,
                    bundleId:bundleId,
                    payload:playload,
                    isSanBox:isSanBox,
                    completion: { (response) in
                        
                        switch response {
                        case .success:
                            print("推送成功")
                            self.tipLabel.text = "推送成功"
                        case .fail(code:let code, msg:let msg):
                            print("推送失败 code=\(code) msg=\(msg)")
                            self.tipLabel.text = "推送失败 code=\(code) msg=\(msg)"
                        }
        })
        
    }

}

