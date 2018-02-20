//
//  FoldersViewController.swift
//  DocReader
//
//  Created by Michael A on 2018-02-18.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import UIKit

private let gridCellIdentifier = "GridCollectionCell"
private let listCellIdentifier = "ListCollectionCell"

class FoldersViewController: UIViewController {
  
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    enum CollectionDisplayOptions {
        case list
        case grid
    }
    
    var folderDisplayType: CollectionDisplayOptions = .list
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(GridCollectionCell.self, forCellWithReuseIdentifier: gridCellIdentifier)
        collectionView.register(ListCollectionCell.self, forCellWithReuseIdentifier: listCellIdentifier)
        addObservers()
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(collectionDisplayTypeChanged), name: NSNotification.Name(rawValue: "CollectionDisplayTypeChanged"), object: nil)
    }
    
    @objc
    fileprivate func collectionDisplayTypeChanged() {
        if folderDisplayType == .grid {
            editButton.isEnabled = true
        } else {
            editButton.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
    
    }
    
}


extension FoldersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 25
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch folderDisplayType {
        case .grid:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: gridCellIdentifier, for: indexPath) as! GridCollectionCell
            return cell
        case .list:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: listCellIdentifier, for: indexPath) as! ListCollectionCell
            return cell
        }
    }
}

extension FoldersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension FoldersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch folderDisplayType {
        case .grid:
            return CGSize(width: 100, height: 150)
        case .list:
            return CGSize(width: view.frame.width, height: 60)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch folderDisplayType {
        case .grid:
            return 5
        case .list:
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch folderDisplayType {
        case .grid:
            return 5
        case .list:
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch folderDisplayType {
        case .grid:
            return UIEdgeInsetsMake(10, 10, 0, 10)
        case .list:
            return UIEdgeInsetsMake(0, 0, 0, 0)
        }
    }
}

extension FoldersViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFolderOptions" {
            if let popoverController = segue.destination as? FoldersPopoverViewController  {
                popoverController.popoverPresentationController?.delegate = self
                popoverController.delegate = self
                popoverController.modalPresentationStyle = .popover
                popoverController.preferredContentSize = CGSize(width: 280, height: 149)
            }
        }
    }
}

extension FoldersViewController: FolderOptionsDelegate {
    func createNewFolder() {
        print("create new folder....")
    }
    
    func switchDisplayType() {
        if folderDisplayType == .list {
            folderDisplayType = .grid
            collectionView.reloadData()
        } else if folderDisplayType == .grid {
            folderDisplayType = .list
            collectionView.reloadData()
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CollectionDisplayTypeChanged"), object: nil)
    }
    
}

struct Folder {
    let title: String
    let date: Date
    var isPasswordProtected = false
    let itemCount: Int
}



