//
//  EditScanViewController.swift
//  DocReader
//
//  Created by Michael A on 2018-02-17.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import UIKit
import Foundation
import TesseractOCR
import SVProgressHUD
import Photos
import PDFKit

private let editImageCellId = "EditImageCell"
private let editingToolsCellId = "EditingToolsCell"

private enum EditingSections: Int {
    case addPage
    case ocrPage
    case cropPage
    case deletePage
}

enum DocumentOrigin {
    case camera
    case photos
}

enum ProgressViewStyle {
    case status
    case progress
    case none
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
    func addingPages()
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
    
    var selectedImages = [UIImage]()
    
    var scannedDocs = [ScannedDoc]()
    
    private var currentPage: Int = 1
    
    private var totalPages: Int = 0 {
        didSet {
            if totalPages == 1 {
                navigationItem.title = "Page 1"
            }
            if totalPages > 2 {
                navigationItem.title = "Page \(currentPage)/ \(totalPages)"
            }
        }
    }
    
    var recognizedText: String?
    
    var progressUpdate: Float = 0
    
    private var recognitionProgress: Float = 0 {
        didSet {
            progressUpdate += recognitionProgress
            print(recognitionProgress)
        }
    }
    
    private let darkOverlay = UIView()
    
    var documentOrigin: DocumentOrigin?
    
    var pdfData: Data?
    
    var pdfGenerator: PDFGenerator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupNavigationBar()
        setupEditingTools()
        print("selected photos count is", selectedImages.count)
        perform(#selector(createPDFS), with: nil, afterDelay: 5)
    }
    @objc
    func createPDFS() {
        pdfGenerator = PDFGenerator(pages: self.selectedImages)
        pdfGenerator?.generatePDF(withCompletion: { (success) in
            if success {
                print("sucessfully generated pdf files")
                
                
//                DispatchQueue.main.async {
//                    let activityController = UIActivityViewController(activityItems: [ "Hello dawg"], applicationActivities: nil)
//                    self.present(activityController, animated: true, completion: nil)
//                }
            }
            
        })
    }
    
    deinit {
        print("Edit scan vc is deiniting")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.pdfData?.removeAll()
        self.pdfData = nil
    }
    
    @objc
    private func didTapCancelButton() {
        let alertController = UIAlertController(title: "Leave Scanning", message: "This will delete all scanned pages. Are you sure?", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Yes", style: .default) { [unowned self] (_) in
            self.scannedDocs.removeAll()
            self.delegate?.removeAllScannedDocs()
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .default)
        alertController.addAction(cancelAction)
        alertController.addAction(okayAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Select Option", message: nil, preferredStyle: .alert)
        
        let pdfAction = UIAlertAction(title: "Save as PDF", style: .default) { (action) in
            //pdfGenerator?.getPDFdata()
//            var images = [UIImage]()
//            for doc in self.scannedDocs {
//                let image = UIImage(cgImage: doc.image, scale: 0.9, orientation: UIImageOrientation.downMirrored)
//                images.append(image)
//            }
//            let A4paperSize = CGSize(width: 595, height: 842)
//            let pdf = SimplePDF(pageSize: A4paperSize)
//            for image in images {
//                pdf.addImage(image)
//            }
//            let activityController = UIActivityViewController(activityItems: [ "Hello dawg"], applicationActivities: nil)
//            self.present(activityController, animated: true, completion: nil)
//            let pdfGenerator = PDFGenerator(pages: self.selectedImages)
//            pdfGenerator.generatePDF(withCompletion: { (success) in
//                if success {
//                    print("sucessfully generated pdf files")
//                        self.pdfData = Data()
//                        self.pdfData = pdfGenerator.getPDFdata()
//                        print(self.pdfData, " data to show")
//
            self.pdfGenerator?.savePDFFile()
           // self.pdfGenerator?.getSavedFile()
            self.perform(#selector(self.printSaved), with: nil, afterDelay: 5)

            let activityController = UIActivityViewController(activityItems: [  "no data"], applicationActivities: nil)
            self.present(activityController, animated: true, completion: nil)
        
//
//            })
            //print(pdfGenerator.getPDFdata() ?? "no data to show")
        }
        
        let photoAction = UIAlertAction(title: "Save to Photo Library", style: .default) { [unowned self] (_) in
            if self.scannedDocs.count > 0 {
                self.scannedDocs.forEach({
                    let image = UIImage(cgImage: $0.image)
                    self.savePhotoToLibrary(image)
                })
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        switch documentOrigin! {
        case .camera:
            alertController.addAction(pdfAction)
            alertController.addAction(photoAction)
            alertController.addAction(cancelAction)
        case .photos:
            alertController.addAction(pdfAction)
            alertController.addAction(cancelAction)
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func savePhotoToLibrary(_ image: UIImage) {
        // Add it to the photo library.
        PHPhotoLibrary.shared().performChanges({
            let _ = PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: { [weak self] success, error in
            if !success {
                print("error saving asset: \(String(describing: error))")
                DispatchQueue.main.async {
                    SVProgressHUD.show(#imageLiteral(resourceName: "error"), status: "Error Saving Try Again")
                }
            } else {
//                self?.dismissProgressView(withCompletion: {
//                    SVProgressHUD.dismiss()
//                })
                DispatchQueue.main.async {
                    SVProgressHUD.show(#imageLiteral(resourceName: "sucess"), status: "Sucessfully Saved")
                }
                print("successfully saved as image to library")
            }
        })
    }
    
    @objc func printSaved() {
        pdfGenerator?.getSavedFile()
    }
    
    // MARK:- Setup Views
    private func setupCollectionView() {
        view.addSubview(photosCollectionView)
        view.addSubview(editingToolsCollectionView)
        photosCollectionView.anchorConstraints(topAnchor: view.topAnchor, topConstant: 0, leftAnchor: view.leftAnchor, leftConstant: 0, rightAnchor: view.rightAnchor, rightConstant: 0, bottomAnchor: editingToolsCollectionView.topAnchor, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        editingToolsCollectionView.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: view.leftAnchor, leftConstant: 0, rightAnchor: view.rightAnchor, rightConstant: 0, bottomAnchor: view.safeAreaLayoutGuide.bottomAnchor, bottomConstant: 0, heightConstant: 100, widthConstant: 0)
    }
    
    private func setupNavigationBar() {
        let titleAttributes = [NSAttributedStringKey.font: UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .semibold), NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        let leftBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancelButton))
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.title = "Page 1 / \(scannedDocs.count)"
        totalPages = scannedDocs.count
    }
    
    private func setupEditingTools() {
        let addPageTool = EditTool.init("Add", image: #imageLiteral(resourceName: "addPageButton"))
        let cropTool = EditTool.init("Crop", image: #imageLiteral(resourceName: "cropButton"))
        let deletePageTool = EditTool.init("Delete", image: #imageLiteral(resourceName: "deletePageButton"))
        let ocrTool = EditTool.init("OCR", image: #imageLiteral(resourceName: "ocr_button"))
        self.toolButtons = [addPageTool, ocrTool, cropTool, deletePageTool]
    }
    
    // MARK:- EditingTools Delegates
   fileprivate func handlePageAddition() {
        switch documentOrigin! {
        case .camera:
            if scannedDocs.count > 1 {
                showAlertController(forTitle: "Unable to add page", message: "2 pages have already been selected. Delete a page then try adding")
                return
            }
            navigationController?.popViewController(animated: true)
            
        case .photos:
            guard scannedDocs.count < 20 else {
                showAlertController(forTitle: "Max Selection", message: "You have selected a maximum of 20 photos")
                return
            }
            delegate?.addingPages()
            navigationController?.popViewController(animated: true)
        }
    }
    
   fileprivate func handlePageDeletion() {
        let index = currentPage - 1
        scannedDocs.remove(at: index)
        delegate?.deletePage(index)
        totalPages -= 1
        photosCollectionView.reloadData()
        updateNavigationTitle(index, totalPages: totalPages)
        if index == totalPages {
            //we know this is the last page
            currentPage -= 1
            updateNavigationTitle(index - 1, totalPages: totalPages)
        }
        
        if totalPages == 0 {
            self.navigationController?.popViewController(animated: true)
            self.scannedDocs.removeAll()
            self.delegate?.removeAllScannedDocs()
        }
    }
    
    fileprivate func handleTextRecognition() {
        DispatchQueue.main.async {
            self.showProgressView(withStyle: .status, statusMessage: "Please wait recognition in process..")
        }
        if let tesseract = G8Tesseract(language: "eng") {
            let index = currentPage - 1
            tesseract.delegate = self
            tesseract.engineMode = .tesseractOnly
            tesseract.pageSegmentationMode = .auto
            let image = UIImage(cgImage: scannedDocs[index].image).g8_blackAndWhite()
            tesseract.image = image
            tesseract.recognize()
            self.recognizedText = tesseract.recognizedText
        }
        
        DispatchQueue.main.async {
            self.dismissProgressView(withCompletion: {
                SVProgressHUD.dismiss {
                    self.handleSegueToOcrViewController()
                }
            })
        }
    }
    
    private func showProgressView(withStyle style: ProgressViewStyle, statusMessage: String?) {
        switch style {
        case .status:
            SVProgressHUD.show(withStatus: statusMessage)
        case .none:
            SVProgressHUD.show()
        case .progress:
            break
        }
        darkOverlay.backgroundColor = .black
        darkOverlay.alpha = 0.5
        if let keyWindow = UIApplication.shared.keyWindow {
            darkOverlay.frame = keyWindow.frame
            keyWindow.addSubview(darkOverlay)
        }
    }
    
    @objc
    private func dismissProgressView(withCompletion completionHandler: (() -> Void)?) {
        DispatchQueue.main.async {
            self.darkOverlay.removeFromSuperview()
        }
        completionHandler?()
    }
    // MARK:- Navigation
    private func handleSegueToOcrViewController() {
        let ocrViewController = OCRViewController()
        let navigationController = UINavigationController(rootViewController: ocrViewController)
        ocrViewController.textView.text = self.recognizedText
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = Int(targetContentOffset.pointee.x / view.frame.width)
        currentPage = index + 1
        updateNavigationTitle(index, totalPages: totalPages)
    }
    
    fileprivate func updateNavigationTitle(_ index: Int, totalPages: Int) {
        navigationItem.title = "Page \(index + 1) / \(totalPages)"
    }
    
}

extension EditScanViewController: G8TesseractDelegate {
    func progressImageRecognition(for tesseract: G8Tesseract!) {
        let progress = Float(tesseract.progress)
        recognitionProgress = progress
    }
}

//MARK:- CollectionView DataSource
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

//MARK:- CollectionView Delegate
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
            DispatchQueue.global(qos: .background).async {
                self.handleTextRecognition()
            }
        case .cropPage:
            print("crop page")
        case .deletePage:
            handlePageDeletion()
        }
    }
    
}

extension EditScanViewController: AlertControllerDelegate { }

// If I want to enable the slide 
//extension UINavigationController {
//    open override func viewDidLoad() {
//        super.viewDidLoad()
//        interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
//    }
//}







