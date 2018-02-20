//
//  PhotosCollectionViewCell.swift
//  CameraSandbox
//
//  Created by Michael A on 2018-02-15.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import UIKit

class PhotosCollectionViewCell: UICollectionViewCell {
    
//    @IBOutlet weak var pageNumberButton: UIButton!
//    @IBOutlet weak var selectedCellImageView: UIImageView!
    @IBOutlet weak var thumbnailImageView: UIImageView!

    var representedAssetIdentifier: String!
    
    var thumbnailImage: UIImage! {
        didSet {
            thumbnailImageView.image = thumbnailImage
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImage = nil
    }
}








