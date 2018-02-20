//
//  EditImageCell.swift
//  DocReader
//
//  Created by Michael A on 2018-02-17.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import UIKit

class EditImageCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .themeColor()
        iv.contentMode = .scaleAspectFit
        iv.layer.shouldRasterize = true
        iv.layer.shadowOpacity = 1
        iv.layer.shadowColor = UIColor.black.cgColor
        //iv.layer.shadowOffset = CGSize.init(width: 2, height: 5)
        iv.layer.shadowOffset = .zero
        iv.layer.shadowRadius = 5
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
