//
//  KeychainManager.swift
//  Yat
//
//  Created by Kanunnikov Dmitriy  on 22.11.2025.
//

import Foundation

struct KeychainManager {
    
    private static let logger = MyLogger(category: "KeychainManager")
    
    static func addSecret(secret: String, byName name: String) {
        let archivedData = try? NSKeyedArchiver.archivedData(
            withRootObject: secret,
            requiringSecureCoding: true
        )
        
        guard let data = archivedData else {
            logger.error("couldn't encode secret '\(name)' as Data")
            return
        }
        
        let attributes = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: name,
            kSecAttrAccessGroup: Config.KEYCHAIN_ACCESS_GROUP,
            kSecValueData: data
        ] as [String: Any]
        
        let status = SecItemAdd(attributes as CFDictionary, nil)
        
        if status != noErr {
            logger.error("couldn't save secret '\(name)' to Keychain: status=\(status)")
        }
    }
    
    static func deleteSecret(byName name: String) {
        let attributes = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: name,
            kSecAttrAccessGroup: Config.KEYCHAIN_ACCESS_GROUP
        ] as [String: Any]
        
        let status = SecItemDelete(attributes as CFDictionary)
        
        if status != noErr {
            logger.error("couldn't delete secret '\(name)' from Keychain: status=\(status)")
        }
    }
    
    static func getSecret(byName name: String) -> String? {
        let attributes = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: name,
            kSecAttrAccessGroup: Config.KEYCHAIN_ACCESS_GROUP,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnData: true
        ] as [String: Any]
        
        var archivedData: AnyObject?
        
        let resultCode = withUnsafeMutablePointer(to: &archivedData) {
            SecItemCopyMatching(attributes as CFDictionary, UnsafeMutablePointer($0))
        }
        
        if resultCode == noErr {
            if let data = archivedData as? Data {
                let secret = try? NSKeyedUnarchiver.unarchivedObject(
                    ofClasses: [NSString.self],
                    from: data
                ) as? String
                
                if let secret = secret {
                    return secret
                } else {
                    logger.error("couldn't decode secret '\(name)' as String")
                }
            } else {
                logger.error("couldn't decode archiveData as Data for secret '\(name)'")
            }
        } else {
            logger.error("couldn't read secret '\(name)' from Keychain: resultCode=\(resultCode)")
        }
        
        return nil
    }
}
