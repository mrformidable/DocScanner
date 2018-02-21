//
//  Extensions.swift
//  DocReader
//
//  Created by Michael A on 2018-02-16.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    static func themeColor() -> UIColor {
        return rgb(red: 96, green: 111, blue: 199)
    }
    static func themeLightPurple() -> UIColor {
        return rgb(red: 227, green: 208, blue: 255)
    }
    static func themePurple() -> UIColor {
        return rgb(red: 156, green: 106, blue: 222)
    }
    static func themePurpleDark() -> UIColor {
        return rgb(red: 80, green: 36, blue: 143)
    }
    static func themePurpleDarker() -> UIColor {
        return rgb(red: 35, green: 0, blue: 81)
    }
    static func themeLightIndigo() -> UIColor {
        return rgb(red: 179, green: 188, blue: 245)
    }
    static func themeIndigo() -> UIColor {
        return rgb(red: 92, green: 106, blue: 196)
    }
    static func themeIndigoDark() -> UIColor {
        return rgb(red: 32, green: 46, blue: 120)
    }
    static func themeIndigoDarker() -> UIColor {
        return rgb(red: 0, green: 6, blue: 57)
    }
    static func seperatorColor() -> UIColor {
        return rgb(red: 240, green: 240, blue: 240)
    }
    static func dividerLineColor() -> UIColor {
        return rgb(red: 204, green: 204, blue: 204)
    }
}

extension UIView {
    
    func anchorConstraints(topAnchor: NSLayoutYAxisAnchor?, topConstant:CGFloat, leftAnchor: NSLayoutXAxisAnchor?,leftConstant:CGFloat ,rightAnchor:NSLayoutXAxisAnchor?, rightConstant: CGFloat,bottomAnchor: NSLayoutYAxisAnchor?, bottomConstant: CGFloat, heightConstant:CGFloat, widthConstant:CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = topAnchor {
            self.topAnchor.constraint(equalTo: top, constant: topConstant).isActive = true
        }
        if let left = leftAnchor {
            self.leftAnchor.constraint(equalTo: left, constant: leftConstant).isActive = true
        }
        if let right = rightAnchor {
            self.rightAnchor.constraint(equalTo: right, constant: rightConstant).isActive = true
        }
        if let bottom = bottomAnchor {
            self.bottomAnchor.constraint(equalTo: bottom, constant: bottomConstant).isActive = true
        }
        if heightConstant > 0 {
            self.heightAnchor.constraint(equalToConstant: heightConstant).isActive = true
        }
        if widthConstant > 0 {
            self.widthAnchor.constraint(equalToConstant: widthConstant).isActive = true
        }
    }
    
    func anchorCenterConstraints(centerXAnchor:NSLayoutXAxisAnchor?, xConstant:CGFloat, centerYAnchor:NSLayoutYAxisAnchor?, yConstant: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        if let centerX = centerXAnchor {
            self.centerXAnchor.constraint(equalTo: centerX, constant: xConstant).isActive = true
        }
        if let centerY = centerYAnchor {
            self.centerYAnchor.constraint(equalTo: centerY, constant: yConstant).isActive = true
        }
    }
}

/*
 Create shakeAnimation for textField
 */
extension UITextField {
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = CGPoint(x: self.center.x - 4, y: self.center.y)
        animation.toValue = CGPoint(x: self.center.x + 4, y: self.center.y)
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        self.layer.add(animation, forKey: "position")
    }
}


extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        //let year = month * 12
        
        let quotient: Int
        let unit: String
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "second"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "min"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "hour"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "day"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "week"
        } else {
            quotient = secondsAgo / month
            unit = "month"
        }
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "s") ago"
    }
}



public protocol AlertControllerDelegate { }

extension AlertControllerDelegate where Self: UIViewController {
    func showAlertController(forTitle title: String?, message: String?) {
        let alertController = UIAlertController(title: title ?? "", message: message ?? "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
}








