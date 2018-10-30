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
    
    var messages = [Message]()
    let cellId = "bubbleCellId"
    
    var selectedChatUser: User? {
        didSet {
            navigationItem.title = selectedChatUser!.name
            observeMessages()
        }
    }
    
    func observeMessages(){
        guard let selectedUser = selectedChatUser else{ return }
        guard let id = Auth.auth().currentUser?.uid else { return }
        let userMessagesRef = Database.database().reference().child("user-messages").child(id)
        userMessagesRef.observe(.childAdded) { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                let message = Message(snapshot:snapshot)
                if message.chatPartnerId() == selectedUser.id{
                    self.messages.append(message)
                    self.collectionView?.reloadData()
                    let indexpath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexpath, at: .bottom, animated: true)
                }
            })
        }
    }
    
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
        guard let toUserId = selectedChatUser?.id else{ return }
        guard let fromUserId = Auth.auth().currentUser?.uid else{ return }
        guard let messageBody = messageTextField.text else { return }
        let timestamp:Int = Int(NSDate().timeIntervalSince1970)
        
        let messageRef = Database.database().reference().child("messages").childByAutoId()
        
        let values = ["text":messageBody, "fromId":fromUserId, "toId":toUserId, "timestamp":"\(timestamp)"]
        messageRef.updateChildValues(values) { (error, returnRef) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            let userMessagesRef = Database.database().reference().child("user-messages")
            let fromUserMessagesRef = userMessagesRef.child(fromUserId)
            let toUserMessagesRef = userMessagesRef.child(toUserId)
            
            let messageId = messageRef.key
            
            fromUserMessagesRef.updateChildValues([messageId:1])
            toUserMessagesRef.updateChildValues([messageId:1])
        }
        messageTextField.text = ""
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
    
    var bottomBarBottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(MessageBubbleCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .onDrag
        collectionView?.alwaysBounceVertical = true
        
        view.addSubview(bottomToolbarView)
        setupBottomToolbarView()
        
        setupCollectionView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    func setupCollectionView(){
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.bottomAnchor.constraint(equalTo: bottomToolbarView.topAnchor).isActive = true
        collectionView?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView?.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    func setupBottomToolbarView(){
        bottomToolbarView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bottomBarBottomConstraint = bottomToolbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomBarBottomConstraint?.isActive = true
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
    
    @objc func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.bottomBarBottomConstraint?.isActive = false
            self.bottomBarBottomConstraint?.constant = -keyboardFrame.size.height
            self.bottomBarBottomConstraint?.isActive = true
        })
    }
}

extension ChatLogController: UICollectionViewDelegateFlowLayout{
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageBubbleCell
        cell.message = messages[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}
