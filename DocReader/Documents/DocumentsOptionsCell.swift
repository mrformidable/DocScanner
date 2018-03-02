//
//  DocumentsOptionsCell.swift
//  DocReader
//
//  Created by Michael A on 2018-02-21.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import UIKit

protocol DocumentsOptionsDelegate: class {
    func didTapChangeCollectionStyle(_ cell: DocumentsOptionsCell)
    func didTapChangeCollectionSortType()
}

class DocumentsOptionsCell: UICollectionViewCell {
    
    weak var delegate: DocumentsOptionsDelegate?
    
   // var documentDisplayType:
    
    lazy var sortedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sorted by Date ▼", for: .normal)
        button.setTitleColor(.themeIndigo(), for: .normal)
        button.addTarget(self, action: #selector(sortedButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var changeDisplayStyle: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "iconList_white"), for: .normal)
        button.backgroundColor = UIColor.themeIndigo()
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(changeDisplayButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    @objc
    private func sortedButtonTapped(_ sender: UIButton) {
        delegate?.didTapChangeCollectionSortType()
    }
    
    @objc
    private func changeDisplayButtonTapped(_ sender: UIButton) {
        delegate?.didTapChangeCollectionStyle(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(sortedButton)
        addSubview(changeDisplayStyle)
        sortedButton.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: nil, leftConstant: 0, rightAnchor: changeDisplayStyle.leftAnchor, rightConstant: -10, bottomAnchor: nil, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        sortedButton.anchorCenterConstraints(centerXAnchor: centerXAnchor, xConstant: 0, centerYAnchor: centerYAnchor, yConstant: 0)
        
        changeDisplayStyle.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: nil, leftConstant: 0, rightAnchor: rightAnchor, rightConstant: -15, bottomAnchor: nil, bottomConstant: 0, heightConstant: 35, widthConstant: 35)
        changeDisplayStyle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
 
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
