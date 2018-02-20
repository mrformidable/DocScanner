//
//  GridCollectionCell.swift
//  DocReader
//
//  Created by Michael A on 2018-02-18.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import UIKit

class GridCollectionCell: UICollectionViewCell {
    
    let folderImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "folder_icon")
        return iv
    }()
    
    let lockImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "lock_icon")
        return iv
    }()
    
    let folderTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Adobe Acrobat"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.semibold)
        return label
    }()
    
    let folderDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "2018 -02- 16 - 0 items"
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(folderImageView)
        folderImageView.addSubview(lockImageView)
        addSubview(folderTitleLabel)
        addSubview(folderDescriptionLabel)
        
        folderImageView.anchorConstraints(topAnchor: topAnchor, topConstant: 20, leftAnchor: leftAnchor, leftConstant: 0, rightAnchor: rightAnchor, rightConstant: 0, bottomAnchor: nil, bottomConstant: 0, heightConstant: 50, widthConstant: 0)
        
        lockImageView.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: nil, leftConstant: 0, rightAnchor: folderImageView.rightAnchor, rightConstant: -10, bottomAnchor: folderImageView.bottomAnchor, bottomConstant: -2, heightConstant: 25, widthConstant: 20)
        
        folderTitleLabel.anchorConstraints(topAnchor: folderImageView.bottomAnchor, topConstant: 15, leftAnchor: folderImageView.leftAnchor, leftConstant: 0, rightAnchor: rightAnchor, rightConstant: -2, bottomAnchor: nil, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        
        folderDescriptionLabel.anchorConstraints(topAnchor: folderTitleLabel.bottomAnchor, topConstant: 0, leftAnchor: folderImageView.leftAnchor, leftConstant: 0, rightAnchor: rightAnchor, rightConstant: -2, bottomAnchor: bottomAnchor, bottomConstant: -2, heightConstant: 0, widthConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
