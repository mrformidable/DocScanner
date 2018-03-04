//
//  PhotosViewController.swift
//  CameraSandbox
//
//  Created by Michael A on 2018-02-15.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import UIKit
import Photos

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
    
    fileprivate var selectedPhotos = [UIImage]()
    
    fileprivate var selectedCount: Int = 0
    
    fileprivate var selectedItems = [[IndexPath: Int]]() {
        didSet {
            if selectedItems.count > 0 {
                selectButton.isEnabled = true
            } else {
                selectButton.isEnabled = false
                selectedPhotos.removeAll()
            }
        }
    }
    
    var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: view.bounds.width * scale,
                      height: view.bounds.height * scale)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetCachedAssets()
        
        collectionView?.allowsMultipleSelection = true
        if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            fetchResult = PHAsset.fetchAssets(with: .image, options: allPhotosOptions)
        }
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
                selectedCount = 0
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectButtonTapped(_ sender: Any) {
        let dateSince1970 = Double(Date().timeIntervalSince1970)
        let date = Date(timeIntervalSince1970: dateSince1970)
        for image in selectedPhotos {
            print(selectedPhotos.count)
            let scannedDoc = ScannedDoc(image: image.cgImage!, date: date)
            scannedDocs.append(scannedDoc)
        }
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
        guard selectedItems.count < 100 else {
            showAlertController(forTitle: "Max Selection", message: "You have selected 100 photos")
            return
        }
        requestImage(atIndex: indexPath)
        selectedItems.append([indexPath: selectedCount + 1])
        selectedCount += 1
        
        print(selectedItems.count, "Select: selected items count")
        print(selectedPhotos.count, "Select: selected photos count")
        print(selectedCount, "Select: selected count")
    }
    
    func requestImage(atIndex indexPath: IndexPath) {
        let asset = fetchResult.object(at: indexPath.item)
        let _ = CGSize(width: view.frame.width * 0.8, height: view.frame.height * 0.8)
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: asset,
                                              targetSize: targetSize,
                                              contentMode: .aspectFit,
                                              options: options,
                                              resultHandler: { image, _ in
                                                guard let image = image else { return }
                                                self.selectedPhotos.append(image)
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        for item in selectedItems {
            if let count = item[indexPath] {
                selectedPhotos.remove(at: count - 1)
            } else {
                print("cannot get current count of selected item")
            }
        }
        selectedItems.remove(at: selectedCount - 1)
        selectedCount -= 1
        
        print(selectedItems.count, "DeSelect: selected items count")
        print(selectedPhotos.count, "DeSelect: selected photos count")
        print(selectedCount, "DeSelect: selected count")
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditFromPhotosVC" {
            if let editScanViewController = segue.destination as? EditScanViewController {
                editScanViewController.delegate = self
                editScanViewController.scannedDocs = self.scannedDocs
                editScanViewController.documentOrigin = .photos
            }
        }
    }
}

extension PhotosViewController: EditScanDelegate {
    func removeAllScannedDocs() {
        scannedDocs.removeAll()
        selectedPhotos.removeAll()
        selectedItems.removeAll()
    }
    
    func deletePage(_ index: Int) {
        scannedDocs.remove(at: index)
        selectedPhotos.remove(at: index)
        selectedItems.remove(at: index)
    }
    
}


