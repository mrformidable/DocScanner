//
//  EditScanViewController.swift
//  DocReader
//
//  Created by Michael A on 2018-02-17.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import UIKit
import Foundation

private let editImageCellId = "EditImageCell"
private let editingToolsCellId = "EditingToolsCell"

private enum EditingSections: Int {
    case addPage
    case filterPage
    case cropPage
    case deletePage
}

struct EditTool {
    let title: String
    let image: UIImage
    init(_ title: String, image: UIImage) {
        self.title = title
        self.image = image
    }
}

class EditScanViewController: UIViewController {
    
    private lazy var photosCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        //layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.groupTableViewBackground
        cv.isPagingEnabled = true
        cv.dataSource = self
        cv.delegate = self
        cv.register(EditImageCell.self, forCellWithReuseIdentifier: editImageCellId)
        return cv
    }()
    
    private lazy var editingToolsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        cv.register(EditingToolsCell.self, forCellWithReuseIdentifier: editingToolsCellId)
        return cv
    }()
    
    private var toolButtons = [EditTool]()
    
    private func setupEditingTools() {
        let addPageTool = EditTool.init("Add", image: #imageLiteral(resourceName: "addPageButton"))
        let cropTool = EditTool.init("Crop", image: #imageLiteral(resourceName: "cropButton"))
        let deletePageTool = EditTool.init("Delete", image: #imageLiteral(resourceName: "deletePageButton"))
        let filterTool = EditTool.init("Filter", image: #imageLiteral(resourceName: "filterButton"))
        self.toolButtons = [addPageTool, filterTool, cropTool, deletePageTool]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        navigationItem.title = "Pages "
        setupEditingTools()
    }
    
    private func setupCollectionView() {
        view.addSubview(photosCollectionView)
        view.addSubview(editingToolsCollectionView)
        photosCollectionView.anchorConstraints(topAnchor: view.topAnchor, topConstant: 0, leftAnchor: view.leftAnchor, leftConstant: 0, rightAnchor: view.rightAnchor, rightConstant: 0, bottomAnchor: editingToolsCollectionView.topAnchor, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        editingToolsCollectionView.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: view.leftAnchor, leftConstant: 0, rightAnchor: view.rightAnchor, rightConstant: 0, bottomAnchor: view.safeAreaLayoutGuide.bottomAnchor, bottomConstant: 0, heightConstant: 100, widthConstant: 0)
    }
}

extension EditScanViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == photosCollectionView {
            return 10
        } else if collectionView == editingToolsCollectionView {
            return toolButtons.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == photosCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: editImageCellId, for: indexPath) as! EditImageCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: editingToolsCellId, for: indexPath) as! EditingToolsCell
            cell.delegate = self
            cell.toolButton.setImage(toolButtons[indexPath.item].image, for: .normal)
            cell.toolLabel.text = toolButtons[indexPath.item].title
            cell.toolButton.tag = indexPath.item
            return cell
        }
    }
    
}


extension EditScanViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
 
    }
}

extension EditScanViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == photosCollectionView {
            return CGSize(width: view.frame.width, height: view.frame.height - 100)
        } else {
            return CGSize(width: view.frame.width / 4, height: 100)
            
        }
    }
}


extension EditScanViewController: EditingToolsDelegate {
    func didTapEditingTool(_ cell: EditingToolsCell) {
        let index = cell.toolButton.tag
        switch EditingSections.init(rawValue: index)! {
        case .addPage:
            print("add page")
        case .filterPage:
            print("filter page")
        case .cropPage:
            print("crop page")
        case .deletePage:
            print("delete page")
        }
    }
    
}










