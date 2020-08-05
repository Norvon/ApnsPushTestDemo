//
//  APNsCerticate.swift
//  ApnsPushTest
//
//  Created by nor on 2020/1/15.
//  Copyright © 2020 nor. All rights reserved.
//

import UIKit

class APNsCerticate {
    
    enum  CertificateType {
        case develop
        case product
    }
    
    
    let type : CertificateType
    let credential : URLCredential
    
    init?(p12Path: String, pwd: String?=nil) {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: p12Path)) else {
            return nil
        }
        
        var item = CFArrayCreate(nil, nil, 0, nil)
        let options = pwd != nil ? [kSecImportExportPassphrase:pwd!] : [:]
        let status = SecPKCS12Import(data as CFData, options as CFDictionary, &item)
        if status != noErr {
            return nil
        }
        
        guard let itemArr = item as? [Any],
              let dict = itemArr.first as? [String: Any] else {
            return nil
        }
        
       guard let secIdentity = dict[kSecImportItemIdentity as String] else {
            return nil
        }
        
        guard let cers = dict[kSecImportItemCertChain as String] as? [SecCertificate] else{
            return nil
        }
        
        let subj = SecCertificateCopySubjectSummary(cers.first!) as String?
        if subj?.contains("Development") == true {
            self.type = .develop
        } else {
            self.type = .product
        }
        
        self.credential = URLCredential(identity: secIdentity as! SecIdentity,
                                        certificates: cers,
                                        persistence: .permanent)
    }
}
