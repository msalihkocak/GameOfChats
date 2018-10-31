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
                //messageTextLabel.textAlignment = .right
                //backgroundColor = UIColor.blue.withAlphaComponent(0.01)
                bubbleView.backgroundColor = MessageBubbleCell.blueColor
                messageTextLabel.textColor = UIColor.white
                profileImageView.isHidden = true
                bubbleRightAnchor?.isActive = true
                bubbleLeftAnchor?.isActive = false
            }else{
                //messageTextLabel.textAlignment = .left
                //backgroundColor = UIColor.red.withAlphaComponent(0.01)
                bubbleView.backgroundColor = MessageBubbleCell.grayColor
                messageTextLabel.textColor = UIColor.black
                profileImageView.isHidden = false
                bubbleRightAnchor?.isActive = false
                bubbleLeftAnchor?.isActive = true
            }
        }
    }
    
    var messageTextLabel:UITextView = {
        let textView = UITextView()
        textView.textColor = UIColor.white
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    static let blueColor = UIColor(r: 0, g: 137, b: 249)
    static let grayColor = UIColor(r: 230, g: 230, b: 230)
    
    var bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "gameofthrones_splash")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(messageTextLabel)
        addSubview(profileImageView)
        
        setupBubbleView()
        setupTextView()
        setupImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupImageView(){
        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    func setupBubbleView(){
        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
        bubbleRightAnchor?.isActive = true
        
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        bubbleLeftAnchor?.isActive = false
        
        bubbleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        bubbleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    func setupTextView(){
        messageTextLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        messageTextLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        messageTextLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        messageTextLabel.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    func fetchUserProfileImage(for user:User){
        guard let msg = message else{ return }
        if user.id == msg.fromId{
            self.profileImageView.loadImageUsingCacheWithUrlString(urlString: user.imageUrlString)
        }
    }
}
