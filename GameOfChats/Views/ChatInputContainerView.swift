//
//  ChatInputContainerView.swift
//  GameOfChats
//
//  Created by Mehmet Salih Koçak on 3.11.2018.
//  Copyright © 2018 Mehmet Salih Koçak. All rights reserved.
//

import UIKit

class ChatInputContainerView: UIView {
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(UIColor(r: 60, g: 140, b: 230), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var messageTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.white
        textField.placeholder = "Write your message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let uploadImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "upload_image_icon")
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        setupInputContainerTopSeperator()
        setupSendButton()
        setupUploadImageView()
        setupMessageTextField()
    }
    
    func setupSendButton(){
        addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: rightAnchor, constant: 8).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2).isActive = true
        sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    func setupMessageTextField(){
        addSubview(messageTextField)
        messageTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 8).isActive = true
        messageTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        messageTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor).isActive = true
        messageTextField.heightAnchor.constraint(equalTo: heightAnchor, multiplier:0.7).isActive = true
    }
    
    func setupUploadImageView(){
        addSubview(uploadImageView)
        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    func setupInputContainerTopSeperator(){
        // Top Seperator View
        let seperator = UIView()
        seperator.translatesAutoresizingMaskIntoConstraints = false
        seperator.backgroundColor = UIColor(r: 235, g: 235, b: 235)
        
        addSubview(seperator)
        seperator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        seperator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        seperator.topAnchor.constraint(equalTo: topAnchor).isActive = true
        seperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
