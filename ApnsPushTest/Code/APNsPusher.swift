//
//  APNsPusher.swift
//  ApnsPushTest
//
//  Created by nor on 2020/1/15.
//  Copyright © 2020 nor. All rights reserved.
//

import UIKit

class APNsPusher: NSObject {
    
    enum Response {
        case success
        case fail(code:Int,msg:String)
    }
    
    typealias APNsCommonResponse = (Response)->()
    
    lazy var session : URLSession! = {
        let session = URLSession(configuration: URLSessionConfiguration.default,
                                 delegate:self,
                                 delegateQueue:OperationQueue.main)
        return session
    }()
    
    var certificate : APNsCerticate?
    
    static let cerPusher    = APNsPusher(p12Path:"test.p12", pwd:"")!
    static let devCerPusher = APNsPusher(p12Path:"dev.p12", pwd:"")!
    
    init?(p12Path: String, pwd: String?=nil) {
        let path = Bundle.main.path(forResource:p12Path, ofType:nil) ?? p12Path
        
        assert(p12Path.count > 0, "未指定 p12 的文件")
        
        guard let cer = APNsCerticate(p12Path: path, pwd: pwd) else {
            return nil
        }
        self.certificate = cer
    }
    
    func push(token: String,
              bundleId: String,
              payload:[String: Any],
              isSanBox: Bool,
              completion: @escaping APNsCommonResponse) {
        
        var url: String
        if isSanBox {
            url = "https://api.sandbox.push.apple.com/3/device/" + token
        } else {
            url = "https://api.push.apple.com/3/device/" + token
        }
        
        var req = URLRequest(url: URL(string: url)!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(bundleId, forHTTPHeaderField:"apns-topic")
        
        req.httpBody = try? JSONSerialization.data(withJSONObject:payload, options:.prettyPrinted)
        
        
        let task = self.session.dataTask(with:req) { (data,response,error) in
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            var reason : String? = nil
            if let data = data,
                let dict = try? JSONSerialization.jsonObject(with:data, options:.allowFragments) as? [String:Any]{
                reason = dict["reason"] as? String
            }
            if statusCode == 200 {
                completion(.success)
            } else {
                completion(.fail(code:statusCode ?? 400, msg:reason ?? error!.localizedDescription))
            }
        }
        
        task.resume()
    }
}

// 服务器要求本地证书
extension APNsPusher: URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        let space = challenge.protectionSpace
        switch space.authenticationMethod {
        case NSURLAuthenticationMethodServerTrust:
            
            if let trust = space.serverTrust {
                let credential = URLCredential(trust: trust)
                completionHandler(.useCredential, credential)
            } else {
                completionHandler(.rejectProtectionSpace, nil)
            }
            
        case NSURLAuthenticationMethodClientCertificate:
            
            if let credential = self.certificate?.credential {
                completionHandler(.useCredential,credential)
            } else {
                completionHandler(.performDefaultHandling,nil)
            }
            
        default:
            completionHandler(.performDefaultHandling,nil)
        }
        
        print("didReceive challenge \(space.authenticationMethod) \(space.host) \(space.port) \(space.serverTrust.debugDescription)")
    }
}
