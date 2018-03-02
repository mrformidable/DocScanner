//
//  ListCollectionCell.swift
//  DocReader
//
//  Created by Michael A on 2018-02-18.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import UIKit

class ListCollectionCell: UICollectionViewCell {
    
    var folder: Folder? {
        didSet {
            guard let folder = folder else {  return  }
            nameLabel.text = folder.name
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
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Adobe Acrobat"
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold)
        return label
    }()
    
    let descriptionLabel: UILabel = {
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
    
     let seperatorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        addSubview(imageView)
        imageView.addSubview(lockImageView)
        addSubview(nameLabel)
        addSubview(descriptionLabel)
        addSubview(detailDisclosure)
        addSubview(seperatorLineView)
        
        imageView.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: leftAnchor, leftConstant: 15, rightAnchor: nil, rightConstant: 0, bottomAnchor: nil, bottomConstant: 0, heightConstant: 40, widthConstant: 40)
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        lockImageView.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: nil, leftConstant: 0, rightAnchor: imageView.rightAnchor, rightConstant: -3, bottomAnchor: imageView.bottomAnchor, bottomConstant: -6, heightConstant: 15, widthConstant: 10)
        
        nameLabel.anchorConstraints(topAnchor: imageView.topAnchor, topConstant: 0, leftAnchor: imageView.rightAnchor, leftConstant: 10, rightAnchor: detailDisclosure.leftAnchor, rightConstant: -1, bottomAnchor: nil, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        
        descriptionLabel.anchorConstraints(topAnchor: nameLabel.bottomAnchor, topConstant: 3, leftAnchor: imageView.rightAnchor, leftConstant: 10, rightAnchor: detailDisclosure.leftAnchor, rightConstant: -5, bottomAnchor: imageView.bottomAnchor, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        
        detailDisclosure.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: nil, leftConstant: 0, rightAnchor: rightAnchor, rightConstant: -10, bottomAnchor: nil, bottomConstant: 0, heightConstant: 20, widthConstant: 20)
        detailDisclosure.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        seperatorLineView.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: imageView.leftAnchor, leftConstant: 0, rightAnchor: rightAnchor, rightConstant: 0, bottomAnchor: bottomAnchor, bottomConstant: 0, heightConstant: 0.5, widthConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
