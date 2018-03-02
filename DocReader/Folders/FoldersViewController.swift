//
//  FoldersViewController.swift
//  DocReader
//
//  Created by Michael A on 2018-02-18.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import UIKit

enum CollectionDisplayOptions {
    case list
    case grid
}

private let gridCellIdentifier = "GridCollectionCell"
private let listCellIdentifier = "ListCollectionCell"
private let folderMenuCellIdentifier = "FolderOptionsHeaderCell"

class FoldersViewController: UIViewController {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var collectionView: UICollectionView!
   
    var folderDisplayType: CollectionDisplayOptions = .list
    
    var folders = [Folder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(FolderMenuCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: folderMenuCellIdentifier)
        collectionView.register(GridCollectionCell.self, forCellWithReuseIdentifier: gridCellIdentifier)
        collectionView.register(ListCollectionCell.self, forCellWithReuseIdentifier: listCellIdentifier)
        loadFolders()
    }
    
    deinit {
        print("folders vc is deiniting..")
    }
    
    fileprivate func loadFolders() {
        folders = DataManager.loadAll(Folder.self)
        print(folders.count)
        collectionView.reloadData()
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
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        print("edit button tapped")
    }
    
}


extension FoldersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return folders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch folderDisplayType {
        case .grid:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: gridCellIdentifier, for: indexPath) as! GridCollectionCell
            cell.folder = folders[indexPath.item]
            return cell
        case .list:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: listCellIdentifier, for: indexPath) as! ListCollectionCell
            cell.folder = folders[indexPath.item]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let folderMenuView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: folderMenuCellIdentifier, for: indexPath) as! FolderMenuCell
        folderMenuView.delegate = self
        return folderMenuView
    }
}

extension FoldersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.pushViewController(DocumentsViewController(), animated: true)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 60)
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

extension FoldersViewController: FolderMenuCellDelegate {
    func didTapAddFolder() {
        let alertStoryboard = UIStoryboard(name: "AlertController", bundle: nil)
        let alertController = alertStoryboard.instantiateViewController(withIdentifier: "AlertController") as! AddFolderAlertController
        alertController.delegate = self
        present(alertController, animated: true, completion: nil)
    }
    
    func didTapChangeCollectionStyle(_ cell: FolderMenuCell) {
        if folderDisplayType == .list {
            folderDisplayType = .grid
            collectionView.reloadData()
            cell.changeDisplayStyle.setImage(#imageLiteral(resourceName: "iconList_themeColor"), for: .normal)
            cell.changeDisplayStyle.backgroundColor = .white
        } else if folderDisplayType == .grid {
            folderDisplayType = .list
            collectionView.reloadData()
            cell.changeDisplayStyle.setImage(#imageLiteral(resourceName: "iconList_white"), for: .normal)
            cell.changeDisplayStyle.backgroundColor = .themeColor()
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CollectionDisplayTypeChanged"), object: nil)
    }
    
    func didTapChangeCollectionSortType() {
        let alertController = UIAlertController(title: "Sort by:", message: nil, preferredStyle: .actionSheet)
        let nameAction = UIAlertAction(title: "Name", style: .default) { (action) in
            
        }
        
        let dateAction = UIAlertAction(title: "Date", style: .default) { (action) in
        }
        
        let sizeAction = UIAlertAction(title: "Size", style: .default) { (action) in
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(nameAction)
        alertController.addAction(dateAction)
        alertController.addAction(sizeAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)

    }
    
    
}

extension FoldersViewController: FolderOptionsDelegate {
    func createNewFolder() {
        let alertStoryboard = UIStoryboard(name: "AlertController", bundle: nil)
        let alertController = alertStoryboard.instantiateViewController(withIdentifier: "AlertController") as! AddFolderAlertController
        alertController.delegate = self
        present(alertController, animated: true, completion: nil)
    }
    
    func switchDisplayType() {
        switchBetweenGridorListView()
    }
    
    func switchBetweenGridorListView() {
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

extension FoldersViewController: AddFolderControllerDelegate {
    func didTapCreateNewFolder(name: String, secureLock: Bool) {
        let dateSince1970 = Double(Date().timeIntervalSince1970)
        let date = Date(timeIntervalSince1970: dateSince1970)
        let newFolder = Folder(name: name, date: date, isPasswordProtected: false, uniqueIdentifier: UUID())
        newFolder.saveNewFolder()
        folders.insert(newFolder, at: 0)
        collectionView.reloadData()
    }
}


