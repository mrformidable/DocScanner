//
//  DocumentsViewController.swift
//  DocReader
//
//  Created by Michael A on 2018-02-21.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import UIKit

private let documentListCellIdentifier = "DocumentsListCellId"
private let documentGridCellIdentifier = "DocumentsGridCellId"
private let documentHeaderCellIdentifier = "DocumentsHeaderCellId"

class DocumentsViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    var documentDisplayType: CollectionDisplayOptions = .list
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        navigationController?.navigationBar.tintColor = .white
    }
    
    deinit {
        print("doc view is deinitializing")
    }
    
    private func setupCollectionView() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.register(DocumentsOptionsCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: documentHeaderCellIdentifier)
        collectionView.register(DocumentsGridCollectionCell.self, forCellWithReuseIdentifier: documentGridCellIdentifier)
        collectionView.register(DocumentsListCollectionCell.self, forCellWithReuseIdentifier: documentListCellIdentifier)
    }

}


extension DocumentsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch documentDisplayType {
        case .grid:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: documentGridCellIdentifier, for: indexPath) as! DocumentsGridCollectionCell
            return cell
        case .list:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: documentListCellIdentifier, for: indexPath) as! DocumentsListCollectionCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let documentOptionsView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: documentHeaderCellIdentifier, for: indexPath) as! DocumentsOptionsCell
        documentOptionsView.delegate = self
       return documentOptionsView
    }
}

extension DocumentsViewController: UICollectionViewDelegate {
    
}

extension DocumentsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch documentDisplayType {
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
        switch documentDisplayType {
        case .grid:
            return 5
        case .list:
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch documentDisplayType {
        case .grid:
            return 0
        case .list:
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch documentDisplayType {
        case .grid:
            return UIEdgeInsetsMake(10, 10, 0, 10)
        case .list:
            return UIEdgeInsetsMake(0, 0, 0, 0)
        }
    }
}

extension DocumentsViewController: DocumentsOptionsDelegate {
    func didTapChangeCollectionStyle(_ cell: DocumentsOptionsCell) {
        if documentDisplayType == .list {
            documentDisplayType = .grid
            collectionView.reloadData()
            cell.changeDisplayStyle.setImage(#imageLiteral(resourceName: "iconList_themeColor"), for: .normal)
            cell.changeDisplayStyle.backgroundColor = .white
        } else if documentDisplayType == .grid {
            documentDisplayType = .list
            collectionView.reloadData()
            cell.changeDisplayStyle.setImage(#imageLiteral(resourceName: "iconList_white"), for: .normal)
            cell.changeDisplayStyle.backgroundColor = .themeColor()
        }
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



