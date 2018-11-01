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
        let userMessagesRef = Database.database().reference().child("user-messages").child(id).child(selectedUser.id)
        userMessagesRef.observe(.childAdded) { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                let message = Message(snapshot:snapshot)
                self.messages.append(message)
                self.collectionView?.reloadData()
                let indexpath = IndexPath(row: self.messages.count - 1, section: 0)
                self.collectionView?.scrollToItem(at: indexpath, at: .bottom, animated: true)
            })
        }
    }
    
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
            let fromUserMessagesRef = userMessagesRef.child(fromUserId).child(toUserId)
            let toUserMessagesRef = userMessagesRef.child(toUserId).child(fromUserId)
            
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
    
    lazy var inputContainerView:UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        containerView.backgroundColor = UIColor(r: 245, g: 245, b: 245)
        
        setupInputContainerTopSeperatorInside(view:containerView)
        setupSendButtonInside(view:containerView)
        setupMessageTextFieldInside(view:containerView)
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
    }
    
    func setupCollectionView(){
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(MessageBubbleCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    func setupSendButtonInside(view:UIView){
        view.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 8).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2).isActive = true
        sendButton.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func setupMessageTextFieldInside(view:UIView){
        view.addSubview(messageTextField)
        messageTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 8).isActive = true
        messageTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        messageTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        messageTextField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier:0.7).isActive = true
    }
    
    func setupInputContainerTopSeperatorInside(view:UIView){
        // Top Seperator View
        let seperator = UIView()
        seperator.translatesAutoresizingMaskIntoConstraints = false
        seperator.backgroundColor = UIColor(r: 235, g: 235, b: 235)
        
        view.addSubview(seperator)
        seperator.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        seperator.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        seperator.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        seperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
}

extension ChatLogController: UICollectionViewDelegateFlowLayout{
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageBubbleCell
        cell.message = messages[indexPath.row]
        if let user = selectedChatUser{
            cell.fetchUserProfileImage(for: user)
        }
        
        setupCellBubbles(for: cell, and: messages[indexPath.row])
        return cell
    }
    
    func setupCellBubbles(for cell:MessageBubbleCell, and message:Message){
        if message.fromId == Auth.auth().currentUser?.uid{
            cell.bubbleView.backgroundColor = MessageBubbleCell.blueColor
            cell.messageTextLabel.textColor = UIColor.white
            cell.hideProfileImage()
        }else{
            cell.bubbleView.backgroundColor = MessageBubbleCell.grayColor
            cell.messageTextLabel.textColor = UIColor.black
            cell.showProfileImage()
        }
        cell.bubbleWidthAnchor?.constant = estimatedFrameForText(text: message.text).width + 32
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height:CGFloat = 80
        height =  estimatedFrameForText(text: messages[indexPath.row].text).height + 17
        return CGSize(width: UIScreen.main.bounds.width, height: height)
    }
    
    private func estimatedFrameForText(text:String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 6
    }
}
