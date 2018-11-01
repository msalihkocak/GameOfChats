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
            if message!.imageUrl != ""{
                messageImageView.loadImageUsingCacheWithUrlString(urlString: message!.imageUrl)
                messageTextLabel.text = ""
                messageImageView.isHidden = false
                messageTextLabel.isHidden = true
            }else{
                messageImageView.image = nil
                messageTextLabel.text = message!.text
                messageImageView.isHidden = true
                messageTextLabel.isHidden = false
            }
        }
    }
    
    var messageTextLabel:UITextView = {
        let textView = UITextView()
        textView.textColor = UIColor.white
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.clear
        textView.isEditable = false
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
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor: NSLayoutConstraint?
    
    var profileLeftAnchor: NSLayoutConstraint?
    var profileWidthAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(messageTextLabel)
        addSubview(profileImageView)
        
        setupBubbleView()
        setupTextView()
        setupImageView()
        setupMessageImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupMessageImageView(){
        bubbleView.addSubview(messageImageView)
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
    }
    
    func setupImageView(){
        profileLeftAnchor = profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8)
        profileLeftAnchor?.isActive = true
        
        profileImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        profileWidthAnchor = profileImageView.widthAnchor.constraint(equalToConstant: 32)
        profileWidthAnchor?.isActive = true
        
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    func showProfileImage(){
        bubbleRightAnchor?.isActive = false
        profileLeftAnchor?.isActive = true
        profileWidthAnchor?.constant = 32
        bubbleLeftAnchor?.isActive = true
    }
    
    func hideProfileImage(){
        profileLeftAnchor?.isActive = false
        profileWidthAnchor?.constant = 0
        bubbleLeftAnchor?.isActive = false
        bubbleRightAnchor?.isActive = true
    }
    
    func setupBubbleView(){
        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        bubbleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
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
