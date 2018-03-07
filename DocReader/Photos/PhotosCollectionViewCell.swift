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
    
    lazy var pageNumberButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel!.textAlignment = .right
        button.backgroundColor = UIColor.themeIndigo()
        button.isHidden = true
        return button
    }()
    
    var representedAssetIdentifier: String!
    
    var thumbnailImage: UIImage! {
        didSet {
            thumbnailImageView.image = thumbnailImage
        }
    }
    
    override var isSelected: Bool {
        didSet {
            thumbnailImageView.layer.borderColor = UIColor.green.cgColor
            thumbnailImageView.layer.borderWidth = isSelected ? 5 : 0
            //pageNumberButton.isHidden = isSelected ? false : true
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(pageNumberButton)
        pageNumberButton.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: nil, leftConstant: 0, rightAnchor: rightAnchor, rightConstant: 0, bottomAnchor: bottomAnchor, bottomConstant: 0, heightConstant: 25, widthConstant: 0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImage = nil
    }
}








