//
//  BiometricAuthentication.swift
//  DocReader
//
//  Created by Michael A on 2018-02-20.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import Foundation
import LocalAuthentication

class BiometricAuthentication {
    
    fileprivate let context = LAContext()
    
    fileprivate func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func authenticateUser(_ completion: @escaping (String?) -> ()) {
        guard canEvaluatePolicy() else {
            completion("Touch ID not available")
            return
        }
        
        let reason = NSLocalizedString("Touch Id needed to enable secure access only", comment: "")
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
            if error != nil {
                let message: String
                switch error! {
                case LAError.authenticationFailed:
                    message = "There was a problem verifying your identity."
                case LAError.userCancel:
                    message = "You pressed cancel."
                case LAError.userFallback:
                    message = "You pressed password."
                case LAError.biometryNotAvailable:
                    message = "Face ID/Touch ID is not available."
                case LAError.biometryNotEnrolled:
                    message = "Face ID/Touch ID is not set up."
                case LAError.biometryLockout:
                    message = "Face ID/Touch ID is locked."
                default:
                    message = "Face ID/Touch ID may not be configured"
                }
                completion(message)
                return
            }
            if success {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}








