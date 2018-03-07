//
//  EditImageCell.swift
//  DocReader
//
//  Created by Michael A on 2018-02-17.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import UIKit

class EditImageCell: UICollectionViewCell {
    
    var scannedDoc: ScannedDoc? {
        didSet {
            if let scannedDoc = scannedDoc {
                imageView.image = UIImage(cgImage: scannedDoc.image)
            }
        }
    }
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.anchorConstraints(topAnchor: topAnchor, topConstant: 25, leftAnchor: leftAnchor, leftConstant: 15, rightAnchor: rightAnchor, rightConstant: -15, bottomAnchor: bottomAnchor, bottomConstant: -20, heightConstant: 0, widthConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
