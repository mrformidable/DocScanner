//
//  EditingToolsCell.swift
//  DocReader
//
//  Created by Michael A on 2018-02-17.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import Foundation
import UIKit

protocol EditingToolsDelegate: class {
    func didTapEditingTool(_ cell: EditingToolsCell)
}

class EditingToolsCell: UICollectionViewCell {
    
    weak var delegate: EditingToolsDelegate?
    
    lazy var toolButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(toolButtonTapped(_:)), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "cropButton"), for: .normal)
        return button
    }()
    
    let toolLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold)
        label.textAlignment = .center
        label.text = "Crop Some Stuff"
        return label
    }()
    
    @objc
    private func toolButtonTapped(_ sender: UIButton) {
        delegate?.didTapEditingTool(self)
    }
    
    private func setupViews() {
        backgroundColor = .white
        addSubview(toolButton)
        toolButton.anchorConstraints(topAnchor: topAnchor, topConstant: 10, leftAnchor: nil, leftConstant: 0, rightAnchor: nil, rightConstant: 0, bottomAnchor: nil, bottomConstant: 0, heightConstant: 60, widthConstant: 60)
        toolButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        addSubview(toolLabel)
        toolLabel.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: leftAnchor, leftConstant: 5, rightAnchor: rightAnchor, rightConstant: -5, bottomAnchor: bottomAnchor, bottomConstant: -5, heightConstant: 0, widthConstant: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
