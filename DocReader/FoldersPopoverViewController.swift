//
//  FoldersPopoverViewController.swift
//  DocReader
//
//  Created by Michael A on 2018-02-19.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import UIKit

protocol FolderOptionsDelegate: class {
    func createNewFolder()
    func switchDisplayType()
}

class FoldersPopoverViewController: UITableViewController {
    
    private enum OptionsType: Int {
        case newFolder
        case switchDisplayType
        case cancel
    }
    
    weak var delegate: FolderOptionsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        switch OptionsType(rawValue: indexPath.row)! {
        case .newFolder:
            cell.imageView?.image = #imageLiteral(resourceName: "add_button_filled")
            cell.textLabel?.text = "Create New Folder"
        case .switchDisplayType:
            cell.imageView?.image = #imageLiteral(resourceName: "grid_icon")
            cell.textLabel?.text = "Switch Display Type"
        case .cancel:
            cell.imageView?.image = #imageLiteral(resourceName: "cancel_icon")
            cell.textLabel?.text = "Cancel"
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch OptionsType(rawValue: indexPath.row)! {
        case .newFolder:
            dismiss(animated: true, completion: nil)
            delegate?.createNewFolder()
        case .switchDisplayType:
            dismiss(animated: true, completion: { [weak self] in
                self?.delegate?.switchDisplayType()
            })
        case .cancel:
            dismiss(animated: true, completion: nil)
        }
    }
    
    
}
