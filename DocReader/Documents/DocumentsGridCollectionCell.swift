//
//  DocumentsGridCollectionCell.swift
//  DocReader
//
//  Created by Michael A on 2018-02-21.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import UIKit

class DocumentsGridCollectionCell: GridCollectionCell {
    
    override func setup() {
        
        imageView.image = #imageLiteral(resourceName: "pdf_icon")
        addSubview(imageView)
        imageView.addSubview(lockImageView)
        addSubview(titeLabel)
        addSubview(descriptionLabel)
        
      imageView.anchorConstraints(topAnchor: topAnchor, topConstant: 10, leftAnchor: nil, leftConstant: 0, rightAnchor: nil, rightConstant: 0, bottomAnchor: nil, bottomConstant: 0, heightConstant: 50, widthConstant: 50)
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        lockImageView.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: nil, leftConstant: 0, rightAnchor: imageView.rightAnchor, rightConstant: -10, bottomAnchor: imageView.bottomAnchor, bottomConstant: -2, heightConstant: 25, widthConstant: 20)
        
        titeLabel.anchorConstraints(topAnchor: imageView.bottomAnchor, topConstant: 13, leftAnchor: leftAnchor, leftConstant: 2, rightAnchor: rightAnchor, rightConstant: -2, bottomAnchor: descriptionLabel.topAnchor, bottomConstant: -3, heightConstant: 0, widthConstant: 0)
        
        descriptionLabel.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: leftAnchor, leftConstant: 2, rightAnchor: rightAnchor, rightConstant: -2, bottomAnchor: nil, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
    }
}
