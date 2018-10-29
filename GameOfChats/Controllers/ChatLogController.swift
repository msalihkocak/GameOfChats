//
//  ChatLogController.swift
//  GameOfChats
//
//  Created by BTK Apple on 29.10.2018.
//  Copyright © 2018 Mehmet Salih Koçak. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController,UITextFieldDelegate {
    
    let bottomToolbarView: UIView = {
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor(r: 245, g: 245, b: 245)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        return bottomView
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(UIColor(r: 60, g: 140, b: 230), for: .normal)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc func handleSend(){
        sendButton.isUserInteractionEnabled = false
        let ref = Database.database().reference().child("messages").childByAutoId()
        guard let messageBody = messageTextField.text else { return }
        let values = ["text":messageBody]
        ref.updateChildValues(values)
        messageTextField.text = ""
        sendButton.isUserInteractionEnabled = true
    }
    
    lazy var messageTextField: UITextField = {
        let textField = UITextField()
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        leftView.backgroundColor = textField.backgroundColor
        textField.leftView = leftView
        textField.leftViewMode = .always
        textField.backgroundColor = UIColor.white
        textField.layer.cornerRadius = 20
        textField.clipsToBounds = true
        textField.placeholder = "Write your message..."
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.white
        
        navigationItem.title = "Chat Log Controller"
        
        view.addSubview(bottomToolbarView)
        setupBottomToolbarView()
    }
    
    func setupBottomToolbarView(){
        bottomToolbarView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bottomToolbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomToolbarView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottomToolbarView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Top Seperator View
        let seperator = UIView()
        seperator.translatesAutoresizingMaskIntoConstraints = false
        seperator.backgroundColor = UIColor(r: 235, g: 235, b: 235)
        bottomToolbarView.addSubview(seperator)
        
        seperator.leftAnchor.constraint(equalTo: bottomToolbarView.leftAnchor).isActive = true
        seperator.rightAnchor.constraint(equalTo: bottomToolbarView.rightAnchor).isActive = true
        seperator.topAnchor.constraint(equalTo: bottomToolbarView.topAnchor).isActive = true
        seperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        bottomToolbarView.addSubview(sendButton)
        setupSendButton()
        bottomToolbarView.addSubview(messageTextField)
        setupMessageTextField()
    }
    
    func setupSendButton(){
        sendButton.rightAnchor.constraint(equalTo: bottomToolbarView.rightAnchor, constant: 8).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: bottomToolbarView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalTo: bottomToolbarView.widthAnchor, multiplier: 0.2).isActive = true
        sendButton.heightAnchor.constraint(equalTo: bottomToolbarView.heightAnchor).isActive = true
    }
    
    func setupMessageTextField(){
        messageTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 8).isActive = true
        messageTextField.centerYAnchor.constraint(equalTo: bottomToolbarView.centerYAnchor).isActive = true
        messageTextField.leftAnchor.constraint(equalTo: bottomToolbarView.leftAnchor, constant: 8).isActive = true
        messageTextField.heightAnchor.constraint(equalTo: bottomToolbarView.heightAnchor, multiplier:0.7).isActive = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text{
            if text.count > 0{
                sendButton.isUserInteractionEnabled = true
            }else{
                sendButton.isUserInteractionEnabled = false
            }
        }
        return true
    }
}
