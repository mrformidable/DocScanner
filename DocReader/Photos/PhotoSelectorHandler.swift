//
//  PhotoSelectorHandler.swift
//  DocReader
//
//  Created by Michael A on 2018-03-04.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import Foundation
import UIKit
import Photos

protocol PhotoSelectorHandlerDelegate: class {
    func didReceiveSelectedImage(_ image: UIImage)
    func removeDeselectedItemFromCollection(atIndex index: Int)
    func showErrorMessage(message: String)
}

class PhotoSelectorHandler: NSObject {
    
    var maximumPhotoSelections: Int
    
    private var allowsSelection = true
    
    var selectedCount = 0
    
    var selectedPhotos = [UIImage]()
    
    var selectedItems = [[IndexPath: Int]]()
    
    weak var delegate: PhotoSelectorHandlerDelegate?
    
    init(maximumPhotoSelection: Int) {
        self.maximumPhotoSelections = maximumPhotoSelection
    }
    
    func selectPhoto(collectionView: UICollectionView, atIndexPath indexPath: IndexPath, asset: PHAsset, targetSize: CGSize) {
        if selectedPhotos.count >= maximumPhotoSelections {
            delegate?.showErrorMessage(message: "You have selected the maximum of \(maximumPhotoSelections) photos")
            allowsSelection = false
            deSelectCollectionViewItem(collectionView, at: indexPath)
        } else { allowsSelection = true }
        
        if allowsSelection {
            requestImage(atIndex: indexPath, asset: asset, targetSize: targetSize, withCompletion: { (image) in
                if let image = image {
                    self.delegate?.didReceiveSelectedImage(image)
                }
            })
            selectedItems.append([indexPath: selectedCount + 1])
            selectedCount += 1
        }
        
    }
    
    func deselectPhoto(atIndexPath indexPath: IndexPath) {
        for item in selectedItems {
            if let count = item[indexPath] {
                selectedPhotos.remove(at: count - 1)
                delegate?.removeDeselectedItemFromCollection(atIndex: count - 1)
            } else {
                print("cannot get current count of selected item")
            }
        }
        selectedItems.remove(at: selectedCount - 1)
        selectedCount -= 1
    }
    
    
    private func requestImage(atIndex indexPath: IndexPath, asset: PHAsset, targetSize: CGSize, withCompletion completionHandler: @escaping (UIImage?) -> Void) {
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { image, _ in
            guard let image = image else {
                completionHandler(nil)
                return
            }
            completionHandler(image)
            
            self.selectedPhotos.append(image)
            
        })
    }

    private func deSelectCollectionViewItem(_ collectionView: UICollectionView, at indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}



/*
 
 
 fileprivate func requestImage(atIndex indexPath: IndexPath, withCompletion completionHandler: @escaping (UIImage?) -> Void) {
 print("Date now not in background", Date().timeIntervalSince1970)
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
 guard let image = image else {
 completionHandler(nil)
 return
 }
 completionHandler(image)
 self.selectedPhotos.append(image)
 
 })
 }
 
 if selectedItems.count >= kMaximumSelection  {
 showAlertController(forTitle: "Max Selection", message: "You have selected \(kMaximumSelection) photos")
 allowSelection = false
 collectionView.deselectItem(at: indexPath, animated: true)
 } else {
 allowSelection = true
 }
 
 if allowSelection {
 requestImage(atIndex: indexPath, withCompletion: { image in
 if let image = image {
 self.addSelectedImageToScannedDocs(image)
 } else {
 print("image from request is nil")
 }
 })
 selectedItems.append([indexPath: selectedCount + 1])
 selectedCount += 1
 
 print(selectedItems.count, "Select: selected items count")
 print(selectedPhotos.count, "Select: selected photos count")
 print(selectedCount, "Select: selected count")
 }
 
 
 */

