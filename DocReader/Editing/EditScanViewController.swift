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
    case ocrPage
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

protocol EditScanDelegate: class {
    func removeAllScannedDocs()
    func deletePage(_ index: Int)
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
    
    weak var delegate: EditScanDelegate?
    
    private var toolButtons = [EditTool]()
    
    var scannedDocs = [ScannedDoc]()
    
    private var currentPage: Int = 1
    
    private var totalPages: Int = 0 {
        didSet {
            if totalPages == 1 {
                navigationItem.title = "Page 1"
            }
            if totalPages == 2 {
                navigationItem.title = "Page \(currentPage)/ \(totalPages)"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupNavigationBar()
        setupEditingTools()
    }
    
    private func setupNavigationBar() {
        let titleAttributes = [NSAttributedStringKey.font: UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .semibold), NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        //navigationItem.title = "Pages \(scannedDocs.count)"
        let leftBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancelButton))
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.title = "Page 1 / \(scannedDocs.count)"
        totalPages = scannedDocs.count
    }
    
    @objc
    private func didTapCancelButton() {
        let alertController = UIAlertController(title: "Leave Scanning", message: "This will delete all scanned pages. Are you sure?", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.scannedDocs.removeAll()
            self.delegate?.removeAllScannedDocs()
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .default)
        alertController.addAction(cancelAction)
        alertController.addAction(okayAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func setupCollectionView() {
        view.addSubview(photosCollectionView)
        view.addSubview(editingToolsCollectionView)
        photosCollectionView.anchorConstraints(topAnchor: view.topAnchor, topConstant: 0, leftAnchor: view.leftAnchor, leftConstant: 0, rightAnchor: view.rightAnchor, rightConstant: 0, bottomAnchor: editingToolsCollectionView.topAnchor, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        editingToolsCollectionView.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: view.leftAnchor, leftConstant: 0, rightAnchor: view.rightAnchor, rightConstant: 0, bottomAnchor: view.safeAreaLayoutGuide.bottomAnchor, bottomConstant: 0, heightConstant: 100, widthConstant: 0)
    }
    
    private func setupEditingTools() {
        let addPageTool = EditTool.init("Add", image: #imageLiteral(resourceName: "addPageButton"))
        let cropTool = EditTool.init("Crop", image: #imageLiteral(resourceName: "cropButton"))
        let deletePageTool = EditTool.init("Delete", image: #imageLiteral(resourceName: "deletePageButton"))
        let ocrTool = EditTool.init("OCR", image: #imageLiteral(resourceName: "ocr_button"))
        self.toolButtons = [addPageTool, ocrTool, cropTool, deletePageTool]
    }
    
    func handlePageAddition() {
        if scannedDocs.count > 1 {
            showAlertController(forTitle: "Unable to add page", message: "2 pages have already been selected. Delete a page then try adding")
            return
        }
        navigationController?.popViewController(animated: true)
    }

    
    func handlePageDeletion() {
        let index = currentPage - 1
        scannedDocs.remove(at: index)
        delegate?.deletePage(index)
        currentPage = 1
        totalPages -= 1
        photosCollectionView.reloadData()
        if totalPages == 0 {
            self.navigationController?.popViewController(animated: true)
            self.scannedDocs.removeAll()
            self.delegate?.removeAllScannedDocs()
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = Int(targetContentOffset.pointee.x / view.frame.width)
        currentPage = index + 1
        navigationItem.title = "Page \(index + 1) / \(totalPages)"
    }
    
}

extension EditScanViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == photosCollectionView {
            return scannedDocs.count
        } else if collectionView == editingToolsCollectionView {
            return toolButtons.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == photosCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: editImageCellId, for: indexPath) as! EditImageCell
            cell.scannedDoc = scannedDocs[indexPath.item]
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
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
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
            handlePageAddition()
        case .ocrPage:
            print("recognize text")
        case .cropPage:
            print("crop page")
        case .deletePage:
            handlePageDeletion()
        }
    }
    
}

extension EditScanViewController: AlertControllerDelegate {}

// If I want to enable the slide 
//extension UINavigationController {
//    open override func viewDidLoad() {
//        super.viewDidLoad()
//        interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
//    }
//}







