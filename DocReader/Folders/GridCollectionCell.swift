//
//  GridCollectionCell.swift
//  DocReader
//
//  Created by Michael A on 2018-02-18.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import UIKit

class GridCollectionCell: UICollectionViewCell {
    
    var folder: Folder? {
        didSet {
            guard let folder = folder else {  return  }
            titeLabel.text = folder.name
            lockImageView.isHidden = folder.isPasswordProtected ? false : true
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            descriptionLabel.text = convertDateToString(folder.date)
        }
    }
    
    private func convertDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "folder_icon")
        return iv
    }()
    
    let lockImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "lock_icon")
        iv.isHidden = true
        return iv
    }()
    
    let titeLabel: UILabel = {
        let label = UILabel()
        label.text = "Adobe Acrobat"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.semibold)
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "2018-02-16 - 0 items"
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    func setup() {
        addSubview(imageView)
        imageView.addSubview(lockImageView)
        addSubview(titeLabel)
        addSubview(descriptionLabel)
        
        imageView.anchorConstraints(topAnchor: topAnchor, topConstant: 20, leftAnchor: leftAnchor, leftConstant: 0, rightAnchor: rightAnchor, rightConstant: 0, bottomAnchor: nil, bottomConstant: 0, heightConstant: 50, widthConstant: 0)
        
        lockImageView.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: nil, leftConstant: 0, rightAnchor: imageView.rightAnchor, rightConstant: -10, bottomAnchor: imageView.bottomAnchor, bottomConstant: -2, heightConstant: 25, widthConstant: 20)
        
        titeLabel.anchorConstraints(topAnchor: imageView.bottomAnchor, topConstant: 13, leftAnchor: leftAnchor, leftConstant: 2, rightAnchor: rightAnchor, rightConstant: -2, bottomAnchor: descriptionLabel.topAnchor, bottomConstant: -3, heightConstant: 0, widthConstant: 0)
        
        descriptionLabel.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: leftAnchor, leftConstant: 2, rightAnchor: rightAnchor, rightConstant: -2, bottomAnchor: nil, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
