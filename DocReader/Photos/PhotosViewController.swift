//
//  PhotosViewController.swift
//  CameraSandbox
//
//  Created by Michael A on 2018-02-15.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import UIKit
import Photos
import SVProgressHUD

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

private let photoCelIdentifier = "PhotosCell"

class PhotosViewController: UICollectionViewController, AlertControllerDelegate {
    
    @IBOutlet weak var selectButton: UIBarButtonItem!
    
    var fetchResult: PHFetchResult<PHAsset>!
    
    fileprivate var thumbnailSize: CGSize!
    
    fileprivate let imageManager = PHCachingImageManager()
    
    fileprivate var previousPreheatRect = CGRect.zero
    
    var scannedDocs = [ScannedDoc]()
    
    var selectedPhotos: [UIImage]?
    
    var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: view.bounds.width * scale,
                      height: view.bounds.height * scale)
    }
    
    var photoSelectorHandler: PhotoSelectorHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetCachedAssets()
        collectionView?.allowsMultipleSelection = true
        if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            fetchResult = PHAsset.fetchAssets(with: .image, options: allPhotosOptions)
        }
        self.photoSelectorHandler = PhotoSelectorHandler(maximumPhotoSelection: 20)
        photoSelectorHandler?.delegate = self
        navigationItem.title = "Photos"
    }
    
    deinit {
        print("photos vc is deinitializing")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateItemSize()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateItemSize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let indexPaths = collectionView?.indexPathsForSelectedItems {
            for indexPath in indexPaths {
                collectionView?.deselectItem(at: indexPath, animated: true)
            }
        }
        photoSelectorHandler?.selectedCount = 0
        selectButton.title = "Select"
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        if let photoSelectorHandler = photoSelectorHandler  {
            if photoSelectorHandler.selectedItems.count > 0 {
                let alertController = UIAlertController(title: "Are you sure?", message: "You have already selected some photos for scan.", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Yes cancel", style: .cancel) { (_) in
                    self.dismiss(animated: true, completion: nil)
                }
                let stopAction = UIAlertAction(title: "Don't cancel", style: .default, handler: nil)
                alertController.addAction(cancelAction)
                alertController.addAction(stopAction)
                present(alertController, animated: true, completion: nil)
            } else {
                dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func selectButtonTapped(_ sender: Any) {
        if photoSelectorHandler?.selectedItems.count == 0 {
            showAlertController(forTitle: "No Photo Selected", message: "Please select a photo")
            return
        }
        selectedPhotos = [UIImage]()
        selectedPhotos = photoSelectorHandler?.selectedPhotos
        SVProgressHUD.show()
        perform(#selector(dismissProgressView), with: nil, afterDelay: 2)
    }
    
    @objc
    func dismissProgressView() {
        SVProgressHUD.dismiss()
        self.performSegue(withIdentifier: "showEditFromPhotosVC", sender: self)
    }
    
    private func updateItemSize() {
        let viewWidth = view.bounds.size.width
        let desiredItemWidth: CGFloat = 60
        let columns: CGFloat = max(floor(viewWidth / desiredItemWidth), 4)
        let padding: CGFloat = 10
        let itemWidth = floor((viewWidth - (columns - 10) * padding) / columns)
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = itemSize
            layout.minimumInteritemSpacing = padding
            layout.minimumLineSpacing = padding
            layout.sectionInset = UIEdgeInsetsMake(15, 10, 4, 10)
        }
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: itemSize.width * scale, height: itemSize.height * scale)
    }
    
    // MARK: UIScrollView
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    // MARK: Asset Caching
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // The preheat window is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCelIdentifier, for: indexPath) as! PhotosCollectionViewCell
        // Request an image for the asset from the PHCachingImageManager.
        let asset = fetchResult.object(at: indexPath.item)
        
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
                cell.thumbnailImage = image
            }
        })
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = fetchResult.object(at: indexPath.item)
        photoSelectorHandler?.selectPhoto(collectionView: collectionView, atIndexPath: indexPath, asset: asset, targetSize: targetSize)
        updateNavTitle()
        
    }
    
    func updateNavTitle() {
        if let selectedPhotos = photoSelectorHandler?.selectedItems.count {
            navigationItem.title = " \(String(describing: selectedPhotos)) Photos Selected"
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        photoSelectorHandler?.deselectPhoto(atIndexPath: indexPath)
        updateNavTitle()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditFromPhotosVC" {
            if let editScanViewController = segue.destination as? EditScanViewController {
                editScanViewController.delegate = self
                editScanViewController.scannedDocs = self.scannedDocs
                editScanViewController.documentOrigin = .photos
                if let selectedPhotos = self.selectedPhotos {
                    editScanViewController.selectedImages = selectedPhotos
                } else {
                    print("no photos selected")
                }
            }
        }
    }
}


extension PhotosViewController {
    fileprivate func addSelectedImageToScannedDocs(_ image: UIImage) {
        DispatchQueue.global(qos: .background).async {
            let dateSince1970 = Double(Date().timeIntervalSince1970)
            let date = Date(timeIntervalSince1970: dateSince1970)
            let scannedDoc = ScannedDoc(image: image.cgImage!, date: date)
            self.scannedDocs.append(scannedDoc)
        }
    }
    
    fileprivate func removeDeselectedImageFromScannedDocs(_ index: Int) {
        DispatchQueue.global(qos: .background).async {
            self.scannedDocs.remove(at: index)
        }
    }
}

extension PhotosViewController: PhotoSelectorHandlerDelegate {
    func removeDeselectedItemFromCollection(atIndex index: Int) {
        removeDeselectedImageFromScannedDocs(index)
    }
    
    func didReceiveSelectedImage(_ image: UIImage) {
        addSelectedImageToScannedDocs(image)
    }
    
    func showErrorMessage(message: String) {
        showAlertController(forTitle: "Invalid Selection", message: message)
    }
    
}

extension PhotosViewController: EditScanDelegate {
    func removeAllScannedDocs() {
        photoSelectorHandler?.selectedPhotos.removeAll()
        photoSelectorHandler?.selectedItems.removeAll()
        scannedDocs.removeAll()
        navigationItem.title = "Photos"
    }
    
    func deletePage(_ index: Int) {
        photoSelectorHandler?.selectedPhotos.remove(at: index)
        photoSelectorHandler?.selectedItems.remove(at: index)
        scannedDocs.remove(at: index)
    }
    
    func addingPages() {
        updateNavTitle()
        selectButton.title = "Proceed"
    }
    
}


