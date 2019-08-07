//
//  customViews.swift
//  kwikut
//
//  Created by Apple on 06/08/2019.
//  Copyright © 2019 devstop. All rights reserved.
//

import UIKit

class customViews: UIView {
    

    
    let textLabel: UILabel = {
        let label = UILabel()
        let formattedString = NSMutableAttributedString()
        formattedString.bold("15")
        formattedString.normal(" SECS")
        label.attributedText = formattedString
        label.textColor = .black
//        label.font = .systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let detailTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "(5 clips)"
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(textLabel)
        textLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        let centerY = NSLayoutConstraint(item: textLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 0.8, constant: 0)
        NSLayoutConstraint.activate([centerY])
//        textLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        addSubview(detailTextLabel)
        detailTextLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: -7).isActive = true
        detailTextLabel.centerXAnchor.constraint(equalTo: textLabel.centerXAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "BebasNeue-Regular", size: 40)!]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "BebasNeue-Regular", size: 18)!]
        let normal = NSMutableAttributedString(string:text, attributes: attrs)
//        let normal = NSAttributedString(string: text)
        append(normal)
        
        return self
    }
}
