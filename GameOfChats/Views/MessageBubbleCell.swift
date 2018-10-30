//
//  MessageBubbleCell.swift
//  GameOfChats
//
//  Created by Mehmet Salih Koçak on 30.10.2018.
//  Copyright © 2018 Mehmet Salih Koçak. All rights reserved.
//

import UIKit
import Firebase

class MessageBubbleCell: UICollectionViewCell {
    
    var message:Message? {
        didSet{
            messageTextLabel.text = message!.text
            if message!.fromId == Auth.auth().currentUser?.uid{
                messageTextLabel.textAlignment = .right
                backgroundColor = UIColor.blue.withAlphaComponent(0.05)
            }else{
                messageTextLabel.textAlignment = .left
                backgroundColor = UIColor.red.withAlphaComponent(0.05)
            }
            setupTextLabel()
        }
    }
    
    var messageTextLabel:UILabel = {
        let label = UILabel()
        label.text = "Anaa"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(messageTextLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTextLabel(){
        messageTextLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -32).isActive = true
        messageTextLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        messageTextLabel.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        messageTextLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
//        if message?.fromId == Auth.auth().currentUser?.uid{
//            messageTextLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
//        }else{
//            messageTextLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
//        }
    }
}
