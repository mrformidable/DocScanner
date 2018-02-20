//
//  ListCollectionCell.swift
//  DocReader
//
//  Created by Michael A on 2018-02-18.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import UIKit

class ListCollectionCell: UICollectionViewCell {
    
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
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold)
        return label
    }()
    
    let folderDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "2018 -02- 16 - 0 items"
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    private let detailDisclosure: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "detail_icon")
        return iv
    }()
    
    private let seperatorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(folderImageView)
        folderImageView.addSubview(lockImageView)
        addSubview(folderTitleLabel)
        addSubview(folderDescriptionLabel)
        addSubview(detailDisclosure)
        addSubview(seperatorLineView)

        
        folderImageView.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: leftAnchor, leftConstant: 15, rightAnchor: nil, rightConstant: 0, bottomAnchor: nil, bottomConstant: 0, heightConstant: 40, widthConstant: 40)
        folderImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
         lockImageView.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: nil, leftConstant: 0, rightAnchor: folderImageView.rightAnchor, rightConstant: -3, bottomAnchor: folderImageView.bottomAnchor, bottomConstant: -6, heightConstant: 15, widthConstant: 10)
        
        folderTitleLabel.anchorConstraints(topAnchor: folderImageView.topAnchor, topConstant: 0, leftAnchor: folderImageView.rightAnchor, leftConstant: 10, rightAnchor: detailDisclosure.leftAnchor, rightConstant: -1, bottomAnchor: nil, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        
        folderDescriptionLabel.anchorConstraints(topAnchor: folderTitleLabel.bottomAnchor, topConstant: 3, leftAnchor: folderImageView.rightAnchor, leftConstant: 10, rightAnchor: detailDisclosure.leftAnchor, rightConstant: -5, bottomAnchor: folderImageView.bottomAnchor, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        
        detailDisclosure.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: nil, leftConstant: 0, rightAnchor: rightAnchor, rightConstant: -10, bottomAnchor: nil, bottomConstant: 0, heightConstant: 20, widthConstant: 20)
         detailDisclosure.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        seperatorLineView.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: folderImageView.leftAnchor, leftConstant: 0, rightAnchor: rightAnchor, rightConstant: 0, bottomAnchor: bottomAnchor, bottomConstant: 0, heightConstant: 0.5, widthConstant: 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
