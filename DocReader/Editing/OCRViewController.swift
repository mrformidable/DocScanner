//
//  OCRViewController.swift
//  DocReader
//
//  Created by Michael A on 2018-03-01.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import UIKit

class OCRViewController: UIViewController, AlertControllerDelegate {

    lazy var textView: UITextView = {
        let tv = UITextView()
        return tv
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(textView)
        textView.anchorConstraints(topAnchor: view.safeAreaLayoutGuide.topAnchor, topConstant: 0, leftAnchor: view.leftAnchor, leftConstant: 0, rightAnchor: view.rightAnchor, rightConstant: 0, bottomAnchor: view.safeAreaLayoutGuide.bottomAnchor, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        setupNavigationController()
    }

    private func setupNavigationController() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .themeIndigoDark()
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(didTapBackButton))
        navigationItem.title = "Recognized Text"
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(didTapActionButton))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if textView.text.isEmpty || textView.text == "" {
            perform(#selector(showOcrErrorMessage), with: nil, afterDelay: 0.5)
        }
    }
    
    @objc
    private func showOcrErrorMessage() {
        showAlertController(forTitle: "No Text Found", message: "No text was found from the image")
    }
    
    @objc
    private func didTapActionButton() {
        guard let text = textView.text, !text.isEmpty else {
            print("text is empty")
            return
        }
        let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    @objc
    func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
}






