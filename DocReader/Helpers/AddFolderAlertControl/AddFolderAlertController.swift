//
//  AddFolderAlertController.swift
//  CustomAlertTest
//
//  Created by Michael A on 2018-02-19.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import UIKit
import AudioToolbox

protocol AddFolderControllerDelegate: class {
    func didTapCreateNewFolder(name: String, secureLock: Bool)
}

final class AddFolderAlertController: UIViewController {
    
    @IBOutlet fileprivate weak var containerView: UIView!
    
    @IBOutlet fileprivate weak var imageView: UIImageView!
    
    @IBOutlet fileprivate weak var folderNameLabel: UILabel!
    
    @IBOutlet fileprivate weak var folderAlertLabel: UILabel!
    
    @IBOutlet fileprivate weak var folderNameTextField: UITextField!
    
    @IBOutlet fileprivate weak var secureLockLabel: UILabel!
    
    @IBOutlet fileprivate weak var enableSecureLockSwitch: UISwitch!
    
    @IBOutlet fileprivate weak var createFolderButton: UIButton!
    
    @IBOutlet weak var containerCenterYConstraint: NSLayoutConstraint!
    
    weak var delegate: AddFolderControllerDelegate?
    
    fileprivate var canUseSecureLock = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
        setImageView()
        setContainer()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissAlertController)))
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleContainerTap)))
        setupKeyboardNotificationObservers()
    }
    
    override func viewDidLayoutSubviews() {
        layoutImageView()
        layoutContainer()
    }
    
    @objc private func handleContainerTap() {
        view.endEditing(true)
    }
    
    @objc fileprivate func dismissAlertController() {
        dismiss(animated: true, completion: nil)
    }
    
    
    fileprivate func setupKeyboardNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }

    @objc
    fileprivate func handleKeyboardWillShow(_ notification: NSNotification) {
        self.containerCenterYConstraint.constant = -70
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { [unowned self] in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc
    fileprivate func handleKeyboardWillHide(_ notification: NSNotification) {
        view.layoutIfNeeded()
        self.containerCenterYConstraint.constant = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { [unowned self] in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    @IBAction func didToggleSecureLock(_ sender: Any) {
        // User needs to validate secure touch Id capabilities
        if !canUseSecureLock {
            let bioAuthentication = BiometricAuthentication()
            bioAuthentication.authenticateUser { (errorMessage) in
                if errorMessage != nil {
                    DispatchQueue.main.async { [unowned self] in
                        self.showAlertController(forTitle: "Unable To Authenticate 😬", message: errorMessage!)
                        self.canUseSecureLock = false
                        self.enableSecureLockSwitch.isOn = false
                    }

                } else {
                    self.canUseSecureLock = true
                    DispatchQueue.main.async { [unowned self] in
                        self.showAlertController(forTitle: "Secure Access Enabled 😃", message: "To access this folder you will be required to use touch id")
                        self.enableSecureLockSwitch.isOn = true
                    }
                }
            }
        }
        // User has already validated that device is secure touch capable
        
    }
    
    
    @IBAction fileprivate func createFolderTapped(_ sender: Any) {
        guard let inputText = folderNameTextField.text else { return }
        if inputText.isEmpty {
            folderNameTextField.shake()
            createAlertAnimation(message: "Please Enter Folder Name")
        } else {
            delegate?.didTapCreateNewFolder(name: inputText, secureLock: enableSecureLockSwitch.isOn)
        }
    }
    
    @IBAction fileprivate func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

fileprivate extension AddFolderAlertController {
    func setupButton() {
        createFolderButton.layer.cornerRadius = 10
        createFolderButton.clipsToBounds = true
    }
    
    func setImageView() {
        imageView.layer.borderColor = UIColor.rgb(red: 92, green: 106, blue: 196).cgColor
        imageView.layer.borderWidth = 1.5
    }
    
    func setContainer() {
        let shape = CAShapeLayer()
        shape.fillColor = UIColor.white.cgColor
        containerView.backgroundColor = .clear
        containerView.layer.insertSublayer(shape, at: 0)
    }
}

fileprivate extension AddFolderAlertController {
    func layoutImageView() {
        imageView.layer.cornerRadius = imageView.frame.width / 2
    }
    
    func layoutContainer() {
        let path = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 10)
        let layer = containerView.layer.sublayers!.first as! CAShapeLayer
        layer.path = path.cgPath
    }
}

fileprivate extension AddFolderAlertController {
    private func createAlertAnimation(message: String) {
        self.folderAlertLabel.isHidden = false
        self.folderAlertLabel.text = message
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            self.folderAlertLabel.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.8, delay: 1, options: .curveEaseIn, animations: {
                self.folderAlertLabel.alpha = 0
                self.folderAlertLabel.isHidden = true
            }, completion: nil)
        })
    }
}

extension AddFolderAlertController: AlertControllerDelegate {}



