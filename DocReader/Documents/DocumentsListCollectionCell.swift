//
//  DocumentsListCollectionCell.swift
//  DocReader
//
//  Created by Michael A on 2018-02-21.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import UIKit

class DocumentsListCollectionCell: ListCollectionCell {
    
    override func setup() {
        
        imageView.image = #imageLiteral(resourceName: "pdf_icon")
        
        addSubview(imageView)
        imageView.addSubview(lockImageView)
        addSubview(nameLabel)
        addSubview(descriptionLabel)
        addSubview(seperatorLineView)
        
        imageView.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: leftAnchor, leftConstant: 15, rightAnchor: nil, rightConstant: 0, bottomAnchor: nil, bottomConstant: 0, heightConstant: 30, widthConstant: 30)
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        lockImageView.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: nil, leftConstant: 0, rightAnchor: imageView.rightAnchor, rightConstant: -3, bottomAnchor: imageView.bottomAnchor, bottomConstant: -6, heightConstant: 15, widthConstant: 10)
        
        nameLabel.anchorConstraints(topAnchor: imageView.topAnchor, topConstant: 0, leftAnchor: imageView.rightAnchor, leftConstant: 10, rightAnchor: rightAnchor, rightConstant: -8, bottomAnchor: descriptionLabel.topAnchor, bottomConstant: -4, heightConstant: 0, widthConstant: 0)
        
        descriptionLabel.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: imageView.rightAnchor, leftConstant: 10, rightAnchor: rightAnchor, rightConstant: -8, bottomAnchor: nil, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        
        seperatorLineView.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: imageView.leftAnchor, leftConstant: 0, rightAnchor: rightAnchor, rightConstant: 0, bottomAnchor: bottomAnchor, bottomConstant: 0, heightConstant: 0.5, widthConstant: 0)
    }
    
}
