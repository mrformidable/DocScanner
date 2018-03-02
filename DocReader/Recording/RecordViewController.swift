//
//  RecordViewController.swift
//  DocReader
//
//  Created by Michael A on 2018-02-19.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import UIKit

class RecordViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        print("Record VC is deinitializing...")
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
